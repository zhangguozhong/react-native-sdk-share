import {DeviceEventEmitter, NativeModules, Platform, NativeEventEmitter} from 'react-native';
const {RNShare} = NativeModules;
const NativeShareEmitter = new NativeEventEmitter(RNShare);

function registerApp(registerAppID) {
    RNShare.registerApp(registerAppID);
}

function registerIosWxApp(registerAppID, universalLink) {
    RNShare.registerApp(registerAppID,universalLink);
}

function isWXAppInstalled(callback) {
    RNShare.isWXAppInstalled(callback);
}

function shareToTimeline(data,defaultCallback,successCallback,failCallback) {

    isWXAppInstalled((code,isInstalled) => {
        if (isInstalled) {
            RNShare.shareToTimeline(data,defaultCallback);
            addListenerWithEventName('WeChat_Resp',successCallback,failCallback);
        }else {
            excuteCallback(failCallback,'微信未安装，请先安装');
        }
    });
}

function shareToSession(data, defaultCallback, successCallback, failCallback) {

    isWXAppInstalled((code,isInstalled) => {
        if (isInstalled) {
            RNShare.shareToSession(data, defaultCallback);
            addListenerWithEventName('WeChat_Resp',successCallback,failCallback);
        } else {
            excuteCallback(failCallback,'微信未安装，请先安装');
        }
    });
}

function addListenerWithEventName(eventName, successCallback, failCallback) {
    if (Platform.OS === 'ios') {
       this.subscription = NativeShareEmitter.addListener(eventName, (value) => {
            if (value.errCode === 0) {
                excuteCallback(successCallback,value);
            } else {
                excuteCallback(failCallback,value);
            }
        });
    } else {
        this.subscription = DeviceEventEmitter.addListener(eventName, (value) => {
            if (value.errCode === 0) {
                excuteCallback(successCallback, value);
            } else {
                excuteCallback(failCallback, value);
            }
        });
    }
}

function removeListener() {
    if (this.subscription) {
        this.subscription.remove();
    }
}

function excuteCallback(callback,value) {
    if (callback) {
        callback(value);
    }
}

export {
    registerApp,registerIosWxApp, shareToSession, shareToTimeline,isWXAppInstalled, removeListener
}
