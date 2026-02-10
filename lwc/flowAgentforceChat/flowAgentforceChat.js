import { LightningElement, track, api } from "lwc";
import createChatGenerations from "@salesforce/apex/ModelsAPIChatGenerations.createChatGenerations";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";

export default class flowAgentforceChat extends LightningElement {
    @track messages = []; // Array to store chat messages
    @api messageOut; //String to output chat transcript
    @api labelText; //Label for message input
    @api messageCollection = []; //Array to store messages for flow output
    @api placeholderText; //Placeholder text for chat window
    @api modelName = 'sfdc_ai__DefaultGPT4Omni'; //Model Name
    @api usageType = 'standard'; //Used in calculating consumed requests
    @api consumedRequests = 0; //Consumed Requests
    iconName = 'utility:copy' //Initial Copy Button Icon
    altText = 'Copy Button' //Initial Copy Button Alttext
    userMessage = ""; // User input message
    isLoading = false; // Track loading state
  
    // Handle user input change
    handleInputChange(event) {
      this.userMessage = event.target.value;
      this.iconName = 'utility:copy'
      this.altText = 'Copy Button'
    }
  
    // Scroll to the bottom of the chat container
    renderedCallback() {
      this.scrollToBottom();
    }

  // Handle pressing 'Enter' key to send message
  handleKeyUp(event) {
    if (event.keyCode === 13) {
      this.handleSendMessage();
    }
  }

    calculateConsumedRequests(messageArray) {
      const totalWords = messageArray.reduce((acc, msg) => acc + msg.message.split(/\s+/).length, 0);
      const apiCallSizeFactor = Math.ceil(totalWords / 1500);
      const multiplier = this.usageType.toLowerCase() === 'starter' ? 7 : 10;
      const newRequests = apiCallSizeFactor * multiplier;
      this.consumedRequests += newRequests;
      this._fireFlowEvent("consumedRequests", this.consumedRequests);
  }
  
    // Handle send message button click
    handleSendMessage() {
      if (this.userMessage.trim()) {
        const timestamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        const userMessageObj = {
          id: this.messages.length + 1,
          text: this.userMessage,
          role: "user",
          isUser: true,
          isAgent: false,
          containerClass: 'chat-message-container user-message',
          bubbleClass: 'chat-bubble user-bubble',
          timestamp: timestamp
        };
  
        // Add user message to the messages array
        this.messages = [...this.messages, userMessageObj];
        this.updateMessageOut(); // Update messageOut property
        this.isLoading = true; // Show loading indicator

        // Add typing indicator message for assistant
        this.addTypingIndicator();
  
        // Prepare message array for API call (skip typing indicator)
        let messageArray = this.messages
          .filter((msg) => !msg.isTyping)
          .map((msg) => ({
            role: msg.isUser ? "user" : "assistant",
            message: msg.text,
          }));
  
        // Call Apex method to fetch chat response
        createChatGenerations({ input: JSON.stringify(messageArray), modelName: this.modelName })
          .then((result) => {
            this.simulateTypingEffect(result);
            this.calculateConsumedRequests(messageArray);            
          })
          .catch((error) => {
            console.error("Error fetching bot response", JSON.stringify(error));
            // Remove typing indicator on error
            this.removeTypingIndicator();
          })
          .finally(() => {
            this.isLoading = false; // Hide loading indicator
          });
  
        this.userMessage = ""; // Clear user input
      }
    }
  
    // Simulate typing effect for the chat response
    simulateTypingEffect(fullText) {
      const words = fullText.split(" ");
      let currentIndex = 0;
      let displayText = "";
      const timestamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  
      const intervalId = setInterval(() => {
        if (currentIndex < words.length) {
          displayText += words[currentIndex] + " ";
          const botResponseObj = {
            id: this.messages.length + 1,
            text: displayText.trim(),
            role: "assistant",
            isUser: false,
            isAgent: true,
            containerClass: 'chat-message-container agent-message',
            bubbleClass: 'chat-bubble agent-bubble',
            timestamp: timestamp
          };
          // Replace the last message if it’s the bot’s typing indicator or previous partial
          const lastIndex = this.messages.length - 1;
          if (lastIndex >= 0 && this.messages[lastIndex].isTyping) {
            this.messages.splice(lastIndex, 1, botResponseObj);
          } else if (currentIndex > 0) {
            this.messages.splice(lastIndex, 1, botResponseObj);
          } else {
            this.messages = [...this.messages, botResponseObj];
          }
          this.updateMessageOut(); // Update messageOut property
          this.scrollToBottom();
          currentIndex++;
        } else {
          clearInterval(intervalId);
        }
      }, 30); // Adjust typing speed (ms per word)
    }
    
    // Update the messageOut property to include all messages as a single string
    updateMessageOut() {
      // Push each message's text to the messageCollection, skipping typing indicator
      this.messageCollection = this.messages.filter(m => !m.isTyping).map((msg) => msg.text);
      // Join the texts to create a single string for messageOut
      this.messageOut = this.messageCollection.join(" ");
      // Trigger the flow event with the updated messageOut
      this._fireFlowEvent("messageOut", this.messageOut);
      // Trigger the flow event with the updated messageCollection
      this._fireFlowEvent("messageCollection", this.messageCollection);
    }
    // Scroll to the bottom of the chat container
    scrollToBottom() {
      const chatContainer = this.template.querySelector(".chat-history");
      if (chatContainer) {
        chatContainer.scrollTop = chatContainer.scrollHeight;
      }
    }

    //Fires event to flow 
    _fireFlowEvent(eventName, data) {
      this.dispatchEvent(new FlowAttributeChangeEvent(eventName, data));
    }

    // Handle Copy Function for full conversation
    handleCopy() {
      if (
          navigator.clipboard && 
          window.isSecureContext
      ) {
          this.iconName = 'utility:check';
          this.altText = 'Text Copied';
          return navigator.clipboard.writeText(
              this.messageOut
          );
      }
    }

    // Handle copying individual message text to clipboard
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

    // Add a typing indicator message for assistant
    addTypingIndicator() {
      const typingMessage = {
        id: `typing-${Date.now()}`,
        text: 'Agent is thinking...',
        role: 'assistant',
        isUser: false,
        isAgent: true,
        isTyping: true,
        containerClass: 'chat-message-container agent-message typing-indicator',
        bubbleClass: 'chat-bubble agent-bubble typing-bubble',
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };
      this.messages = [...this.messages, typingMessage];
      this.scrollToBottom();
    }

    // Remove typing indicator message
    removeTypingIndicator() {
      this.messages = this.messages.filter((msg) => !msg.isTyping);
    }

  addToMessageCollection(messageText) {
    // Check if the messageText is a string
    if (typeof messageText === 'string') {
      // Check if the messageCollection exists
      if (!this.messageCollection) {
        this.messageCollection = [];
      }
      // Add the messageText to the messageCollection
      this.messageCollection.push(messageText);
    } else {
      console.error('Invalid messageText type: ', typeof messageText);
    }
    this._fireFlowEvent("messageCollection", this.messageCollection);
  }

  get noMessages() {
    return this.messages.length === 0;
  }

}