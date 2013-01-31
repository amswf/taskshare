package com.isflash.ui
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.isflash.events.TaskEvent;
	
	import flash.events.MouseEvent;
	
	public class CommitTaskUI extends Panel
	{
		private var titleLabel:Label = new Label();
		private var contentLabel:Label = new Label();
		
		private var titleText:InputText = new InputText();
		private var contentText:TextArea = new TextArea();
		private var commitButton:PushButton = new PushButton();
		
		public function CommitTaskUI()
		{
			this.width = 300;
			this.height = 200;
			
			titleLabel.text = '任务标题：';
			titleLabel.x = 10;
			titleLabel.y = 20;
			this.addChild(titleLabel);
			
			contentLabel.text = '任务内容:';
			contentLabel.x = 10;
			contentLabel.y = 60;
			this.addChild(contentLabel);
			
			titleText.width = 200;
			titleText.height = 20;
			titleText.x = 80;
			titleText.y = 20;
			this.addChild(titleText);
			
			contentText.width = 200;
			contentText.height = 100;
			contentText.x = 80;
			contentText.y = 60;
			this.addChild(contentText);
			
			commitButton.label = '提交';
			commitButton.x = 100;
			commitButton.y = 170;
			commitButton.addEventListener(MouseEvent.CLICK,commit);
			this.addChild(commitButton);
		}
		
		private function commit(e:MouseEvent):void
		{
			var event:TaskEvent = new TaskEvent(TaskEvent.CommitTask);
			event.title = titleText.text;
			event.content = contentText.text;
			this.dispatchEvent(event);
			
			titleText.text = '';
			contentText.text = '';
		}
	}
}