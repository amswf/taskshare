package com.isflash.ui
{
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.TextArea;
	
	public class TaskCell extends Panel
	{
		public function TaskCell(title:String,content:String)
		{
			this.width = 260;
			this.height = 100;
			
			var label:Label = new Label();
			label.text = title;
			label.y = 5;
			label.width = 260;
			label.height = 20;
			this.addChild(label);
			
			var textArea:TextArea = new TextArea();
			textArea.width = 260;
			textArea.y = 25;
			textArea.autoHideScrollBar = true;
			textArea.editable = false;
			textArea.height = 75;
			textArea.text = content;
			this.addChild(textArea);
		}
	}
}