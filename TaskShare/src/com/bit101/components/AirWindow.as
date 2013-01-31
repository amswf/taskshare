package com.bit101.components
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;

	public class AirWindow extends Window
	{
		private var nativeWindow:NativeWindow;
		
		public function AirWindow(win:NativeWindow=null,title:String='')
		{
			var ops:NativeWindowInitOptions = new NativeWindowInitOptions();
			ops.systemChrome = NativeWindowSystemChrome.NONE;
			ops.transparent = true;
			super(null,200,100,title);
			if(win){
				nativeWindow = win;
			}else{
				nativeWindow = new NativeWindow(ops);
			}
			super.width = nativeWindow.width;
			super.height = nativeWindow.height;
			
			nativeWindow.bounds = Screen.mainScreen.visibleBounds;
			nativeWindow.stage.align = StageAlign.TOP_LEFT;
			nativeWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
			hasCloseButton = true;
			this._closeButton.addEventListener(MouseEvent.CLICK,onCloseWin);
			hasMinimizeButton = true;
			this._minimizeButton.x = _width - 30;
			nativeWindow.visible = true;
			nativeWindow.activate();
		}
		
		override protected function onMinimize(event:MouseEvent):void
		{
			nativeWindow.minimize();
		}
		
		private function onCloseWin(event:MouseEvent):void
		{
			nativeWindow.close();
		}
	}
}