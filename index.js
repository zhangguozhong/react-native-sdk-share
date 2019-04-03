import { DeviceEventEmitter,NativeModules,Platform,NativeEventEmitter } from 'react-native';
const { RNShare } = NativeModules;
const NativeShareEmitter = new NativeEventEmitter(RNShare);

export function registerApp(registerAppID) {
    RNShare.registerApp(registerAppID);
}

export function isWXAppInstalled(callback) {
    RNShare.isWXAppInstalled(callback);
}

export function shareToTimeline(data,successCallback,failCallback) {

    isWXAppInstalled((code,isInstalled) => {
        if (isInstalled) {
            RNShare.shareToTimeline(data,successCallback);
            addListenerWithEventName('WeChat_Resp',successCallback,failCallback);
        }else {
            excuteCallback(failCallback,'微信未安装，请先安装');
        }
    });
}

export function shareToSession(data,successCallback,failCallback) {

    isWXAppInstalled((code,isInstalled) => {
        if (isInstalled) {
            RNShare.shareToSession(data, successCallback);
            addListenerWithEventName('WeChat_Resp',successCallback,failCallback);
        }else {
            excuteCallback(failCallback,'微信未安装，请先安装');
        }
    });
}

function addListenerWithEventName(eventName,successCallback,failCallback) {
    if (Platform.OS === 'ios') {
       this.subscription = NativeShareEmitter.addListener(eventName, (value) => {
            if (value.errCode === 0) {
                excuteCallback(successCallback,value);
            } else {
                excuteCallback(failCallback,value);
            }
        });
    }else {
        this.subscription = DeviceEventEmitter.addListener(eventName, (value) => {
            if (value.errCode === 0) {
                excuteCallback(successCallback,value);
            } else {
                excuteCallback(failCallback,value);
            }
        });
    }
}

export function removeListener() { this.subscription && this.subscription.remove(); }

function excuteCallback(callback,value) { callback && callback(value); }
