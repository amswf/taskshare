package com.isflash.ui
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	import com.isflash.events.TaskEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	public class LoginUI extends Sprite
	{
		private var win:Window = new Window(null,0,0,'登录窗');
		private var nameText:InputText = new InputText();
		private var loginButton:PushButton = new PushButton();
		
		public function LoginUI()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(e:Event):void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xccccc,0.2);
			this.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			this.graphics.endFill();
			
			win.width = 300;
			win.height = 200;
			win.x = 250;
			win.y = 200;
			win.draggable = false;
			this.addChild(win);
			
			var label:Label = new Label();
			label.x = 30;
			label.y = 30;
			label.width = 50;
			label.height = 20;
			label.text = '用户名:';
			win.addChild(label);
			
			nameText.x = 80;
			nameText.y = 30;
			nameText.width = 170;
			nameText.height = 20;
			nameText.addEventListener(KeyboardEvent.KEY_DOWN,onLogin);
			win.addChild(nameText);
			
			loginButton.x = 100;
			loginButton.y = 80;
			loginButton.label = '登录';
			loginButton.addEventListener(MouseEvent.CLICK,onLogin);
			win.addChild(loginButton);
		}
		
		private function onLogin(e:Event):void
		{
			var event:TaskEvent = new TaskEvent(TaskEvent.Login);
			event.userName = nameText.text;
			if(e.type == KeyboardEvent.KEY_DOWN){
				if(e['keyCode'] == 13){
					this.dispatchEvent(event);
				}
			}else if(e.type == MouseEvent.CLICK){
				this.dispatchEvent(event);
			}
		}
	}
}