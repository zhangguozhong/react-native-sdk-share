
# react-native-sdk-share

## Getting started

`$ npm install react-native-sdk-share --save`

### Mostly automatic installation

`$ react-native link react-native-sdk-share`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-sdk-share` and add `RNShare.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNShare.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.library.share.RNSharePackage;` to the imports at the top of the file
  - Add `new RNSharePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-sdk-share'
  	project(':react-native-sdk-share').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-sdk-share/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-sdk-share')
  	```

## 配置（请参考微信开放平台文档）

## Demo
```javascript

import { shareToSession,shareToTimeline,registerApp,registerIosWxApp } from 'react-native-sdk-share';

const weiXinSceneType = { session:1,timeLine:2 }; //session=1微信好友，timeLine=2微信朋友圈
const defaultCallback = (error,result) => { console.log(error,result); }; //默认回调方法
const UtilsShare = {

    registerApp:function (registerAppID) {
        registerApp(registerAppID);
    },
    shareDataToWeiXin:function (sceneType,data,successCallback,failCallback) {
        if (sceneType === weiXinSceneType.timeLine) {
            shareToTimeline(data,defaultCallback,successCallback,failCallback);
        }else if (sceneType === weiXinSceneType.session) {
            shareToSession(data,defaultCallback,successCallback,failCallback);
        }
    }
};
export default UtilsShare;
export { weiXinSceneType }

UtilsShare.registerApp('xxx'); //注册app
UtilsShare.shareDataToWeiXin(weiXinSceneType.session,{ type:'text',text:'测试',description:'测试消息' },(data) => {
    console.log('成功回调',data);
},(error) => {
    console.log('错误回调',error);
});

```

## 说明

微信开放平台注册安卓平台使用registerApp，iOS使用registerIosWxApp。

export default UtilsShare;
