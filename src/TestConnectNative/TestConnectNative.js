// If TestConnectNative is an package from npm, you can think this is index.js file
import {NativeModules, Platform} from 'react-native';

const testConnectNative = NativeModules.TestConnectNative;

const bot_id = '<bot-id>';
const bot_name = 'bot-name';
const client_id = '<client-id>';
const client_secret = '<client-secret>';
const identity = generateQuickGuid();

function generateQuickGuid() {
return Math.random().toString(36).substring(2, 15) +
Math.random().toString(36).substring(2, 15);
}

testConnectNative.initialize(bot_id, bot_name, client_id, client_secret, identity);



const TestConnectNative = {

  sendMessage: msg => {
    testConnectNative.sendMessageToNative(msg);
  },

  sendCallback: callback => {
    testConnectNative.sendCallbackToNative(callback);
  },

  exitRN: tag => {
    if (Platform.OS === 'ios') {
      testConnectNative.dismissViewController(tag);
    } else {
      testConnectNative.finishActivity();
    }
  },

  goToNative: tag => {
    if (Platform.OS === 'ios') {
      testConnectNative.goToSecondViewController(tag);
    } else {
      testConnectNative.goToSecondActivity();
    }
  },
};

export default TestConnectNative;
