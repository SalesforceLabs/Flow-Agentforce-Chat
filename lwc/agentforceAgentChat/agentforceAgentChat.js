import { LightningElement, track, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import startSession from '@salesforce/apex/AgentforceAgentController.startSession';
import sendMessageToServer from '@salesforce/apex/AgentforceAgentController.sendMessage';
import endSession from '@salesforce/apex/AgentforceAgentController.endSession';

export default class AgentforceAgentChat extends LightningElement {
    // IMPORTANT: Replace with your actual Einstein Agent ID.
    // You can find this in the URL when viewing your agent in the Einstein Bot Builder.
    @api agentId = '0XxDm000000boZuKAI'; 
    @api bypassUser;
    @api conversationHistory = '';
    @api lastAgentMessage = '';
    @api defaultMessage = '';
    @api autoStart = false;
    @api autoStartDelayMs = 2000;

    @track userInput = '';
    @track chatHistory = [];
    @track isLoading = true;
    @track isTyping = false;

    _key = 0;
    _sessionId = null;
    _sequenceId = 1;
    _autoStartTimeout;

    // Getter for the input placeholder
    get inputPlaceholder() {
        return this.defaultMessage && !this.autoStart ? this.defaultMessage : 'Type your message here...';
    }

    // When the component is added to the page, start a new session.
    connectedCallback() {
        this.startNewSession();
    }

    // Handle rendering rich text content after each render
    renderedCallback() {
        // Use a more specific selector that doesn't rely on the lwc:dom attribute
        const richTextElements = this.template.querySelectorAll('.chat-message-text[data-rich-text]');
        console.log('renderedCallback called, found elements:', richTextElements.length);
        
        richTextElements.forEach((element, index) => {
            const richTextHtml = element.dataset.richText;
            const key = element.dataset.key;
            
            console.log(`Element ${index}:`, {
                key: key,
                richTextHtml: richTextHtml,
                currentInnerHTML: element.innerHTML
            });
            
            // Only update if content has changed (prevent infinite loops)
            if (richTextHtml && element.innerHTML !== richTextHtml) {
                console.log(`Updating element ${index} with rich text HTML`);
                element.innerHTML = richTextHtml;
                
                // Add a data attribute to track that we've processed this element
                element.setAttribute('data-processed', 'true');
            }
        });
    }

    // When the component is removed, end the session to clean up resources.
    disconnectedCallback() {
        if (this._autoStartTimeout) {
            clearTimeout(this._autoStartTimeout);
        }
        if (this._sessionId) {
            endSession({ sessionId: this._sessionId })
                .catch(error => {
                    console.error('Error ending session:', error);
                });
        }
    }

    // Handles starting a new session with the Apex controller.
    startNewSession() {
        this.isLoading = true;
        startSession({ agentId: this.agentId, bypassUser: this.bypassUser })
            .then(result => {
                this._sessionId = result.sessionId;
                // Add the agent's initial greeting to the chat history.
                if(result.agentGreeting) {
                    this.addMessageToHistory(result.agentGreeting, 'inbound');
                }
                this.isLoading = false;

                // If autoStart is enabled and we have a default message, send it automatically after a delay.
                if (this.autoStart && this.defaultMessage) {
                    this._autoStartTimeout = setTimeout(() => {
                        this.userInput = this.defaultMessage;
                        this.sendMessage();
                    }, this.autoStartDelayMs);
                }
            })
            .catch(error => {
                console.error('Error starting session:', error);
                let errorMessage = 'Error starting session. Please check the Agent ID and your user permissions.';
                // Prefer the Apex AuraHandledException message if available
                if (error && error.body && error.body.message) {
                    errorMessage = error.body.message;
                } else if (error && error.message) {
                    errorMessage = error.message;
                }
                this.addMessageToHistory(errorMessage, 'error');
                this.isLoading = false;
            });
    }

    // Utility function to parse markdown-like syntax into HTML
    parseRichText(message) {
        if (!message) return '';
        
        let html = message
            // Escape HTML tags first
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            
            // Convert markdown-like syntax to HTML
            // Bold: **text** or __text__
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/__(.*?)__/g, '<strong>$1</strong>')
            
            // Italic: *text* or _text_
            .replace(/\*([^*]+?)\*/g, '<em>$1</em>')
            .replace(/_([^_]+?)_/g, '<em>$1</em>')
            
            // Code blocks: ```text```
            .replace(/```([\s\S]*?)```/g, '<div class="code-block"><pre><code>$1</code></pre></div>')
            
            // Inline code: `text`
            .replace(/`([^`]+?)`/g, '<code class="inline-code">$1</code>')
            
            // Standard markdown links: [text](url)
            .replace(/\[([^\]]+?)\]\(([^)]+?)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>')
            
            // Alternative link format: "text" (url)
            .replace(/"([^"]+?)"\s*\(([^)]+?)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>')
            
            // Strikethrough: ~~text~~
            .replace(/~~(.*?)~~/g, '<del>$1</del>');

        // Handle lists properly
        const lines = html.split('\n');
        const processedLines = [];
        let inList = false;
        
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            
            // Check if this line is a list item
            const listMatch = line.match(/^[\s]*[-*]\s+(.+)$/);
            
            if (listMatch) {
                if (!inList) {
                    processedLines.push('<ul>');
                    inList = true;
                }
                processedLines.push(`<li>${listMatch[1]}</li>`);
            } else {
                if (inList) {
                    processedLines.push('</ul>');
                    inList = false;
                }
                processedLines.push(line);
            }
        }
        
        // Close list if we ended with a list
        if (inList) {
            processedLines.push('</ul>');
        }
        
        html = processedLines.join('\n');
        
        // Handle line breaks and paragraphs
        html = html
            // Double newline becomes paragraph break
            .replace(/\n\n/g, '</p><p>')
            // Single line breaks (but not within lists)
            .replace(/\n(?![<\/])/g, '<br>');
        
        // Wrap in paragraph tags if not already wrapped
        if (html && !html.startsWith('<') && !html.includes('<p>') && !html.includes('<ul>')) {
            html = '<p>' + html + '</p>';
        }
        
        return html;
    }

    // Utility function to add a message to the chat history array.
    addMessageToHistory(message, type) {
        const isAgent = type === 'inbound';
        const isUser = type === 'outbound';
        const isError = type === 'error';
        
        let containerClass = 'chat-message-container ';
        let bubbleClass = 'chat-bubble ';
        let prefix = isAgent ? 'Agent: ' : 'You: ';
        
        if (isAgent) {
            containerClass += 'agent-message';
            bubbleClass += 'agent-bubble';
            this.lastAgentMessage = message;
            // Notify the flow that the lastAgentMessage has changed.
            this.dispatchEvent(new FlowAttributeChangeEvent('lastAgentMessage', this.lastAgentMessage));
        } else if (isUser) {
            containerClass += 'user-message';
            bubbleClass += 'user-bubble';
        } else if (isError) {
            containerClass += 'error-message';
            bubbleClass += 'error-bubble';
        }

        // Format timestamp
        const now = new Date();
        const timestamp = now.toLocaleTimeString([], { 
            hour: '2-digit', 
            minute: '2-digit' 
        });

        // Parse message for rich text content
        const richTextHtml = this.parseRichText(message);
        
        // Debug logging
        console.log('Original message:', message);
        console.log('Parsed rich text HTML:', richTextHtml);
        
        this.chatHistory = [...this.chatHistory, { 
            key: this._key++, 
            message: message, 
            richTextHtml: richTextHtml,
            containerClass: containerClass,
            bubbleClass: bubbleClass,
            isAgent: isAgent,
            isUser: isUser,
            isError: isError,
            timestamp: timestamp
        }];

        // Update the conversation history string for flow output (skip typing indicators)
        if (type !== 'typing') {
            this.conversationHistory += prefix + message + '\n';
            // Notify the flow that the conversationHistory has changed.
            this.dispatchEvent(new FlowAttributeChangeEvent('conversationHistory', this.conversationHistory));
        }
        
        // Scroll to the bottom of the chat window after adding a message.
        this.scrollToBottom();
    }

    // Handle changes to the user input field.
    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    // Handle pressing 'Enter' key to send message
    handleKeyUp(event) {
        if (event.keyCode === 13) {
            this.sendMessage();
        }
    }

    // Send the user's message to the server using streaming endpoint.
    sendMessage() {
        if (this.userInput && this._sessionId && !this.isLoading && !this.isTyping) {
            const messageToSend = this.userInput;
            this.addMessageToHistory(messageToSend, 'outbound');
            this.userInput = ''; // Clear input immediately
            this.isLoading = true;
            this.isTyping = true;

            // Add typing indicator
            this.addTypingIndicator();

            // Call the Apex method to send the message with sequence ID.
            sendMessageToServer({ 
                sessionId: this._sessionId, 
                message: messageToSend, 
                sequenceId: this._sequenceId 
            })
                .then(result => {
                    // Remove typing indicator
                    this.removeTypingIndicator();
                    
                    // The 'result' is now the complete streaming response parsed by Apex.
                    if (result) {
                        this.addMessageToHistory(result, 'inbound');
                        this._sequenceId++; // Increment sequence ID for next message
                    } else {
                        // Handle cases where the Apex method might return an empty or null string.
                        this.addMessageToHistory('No response from agent.', 'error');
                    }
                    this.isLoading = false;
                    this.isTyping = false;
                })
                .catch(error => {
                    // Remove typing indicator on error
                    this.removeTypingIndicator();
                    
                    // It's helpful to display the actual error message from Apex if available.
                    let errorMessage = 'There was an error sending your message.';
                    if (error && error.body && error.body.message) {
                        errorMessage = error.body.message;
                    }
                    console.error('Error sending message:', JSON.stringify(error));
                    this.addMessageToHistory(errorMessage, 'error');
                    this.isLoading = false;
                    this.isTyping = false;
                });
        }
    }

    // Add a typing indicator to show the agent is processing
    addTypingIndicator() {
        const typingMessage = {
            key: 'typing-indicator',
            message: 'Agent is thinking...',
            containerClass: 'chat-message-container agent-message typing-indicator',
            bubbleClass: 'chat-bubble agent-bubble typing-bubble',
            isAgent: true,
            isUser: false,
            isError: false,
            isTyping: true,
            timestamp: new Date().toLocaleTimeString([], { 
                hour: '2-digit', 
                minute: '2-digit' 
            })
        };
        
        this.chatHistory = [...this.chatHistory, typingMessage];
        this.scrollToBottom();
    }

    // Remove the typing indicator
    removeTypingIndicator() {
        this.chatHistory = this.chatHistory.filter(msg => msg.key !== 'typing-indicator');
    }

    // Utility method to scroll to bottom
    scrollToBottom() {
        setTimeout(() => {
            const chatContainer = this.template.querySelector('.chat-history');
            if(chatContainer) {
                chatContainer.scrollTop = chatContainer.scrollHeight;
            }
        }, 100);
    }

    // Handle copying message text to clipboard
    handleCopyMessage(event) {
        const messageText = event.target.dataset.message;
        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(messageText).then(() => {
                // Temporarily change the icon to indicate success
                const button = event.target;
                const originalIcon = button.iconName;
                button.iconName = 'utility:check';
                setTimeout(() => {
                    button.iconName = originalIcon;
                }, 1500);
            }).catch(err => {
                console.error('Failed to copy message: ', err);
            });
        } else {
            // Fallback for non-secure contexts
            const textArea = document.createElement('textarea');
            textArea.value = messageText;
            document.body.appendChild(textArea);
            textArea.select();
            try {
                document.execCommand('copy');
                // Temporarily change the icon to indicate success
                const button = event.target;
                const originalIcon = button.iconName;
                button.iconName = 'utility:check';
                setTimeout(() => {
                    button.iconName = originalIcon;
                }, 1500);
            } catch (err) {
                console.error('Failed to copy message: ', err);
            }
            document.body.removeChild(textArea);
        }
    }
}













