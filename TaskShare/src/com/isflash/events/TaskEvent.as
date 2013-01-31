package com.isflash.events
{
	import flash.events.Event;
	
	public class TaskEvent extends Event
	{
		public static const Login:String = 'login';
		public var userName:String;
		
		public static const CommitTask:String = 'commit_task';
		public var title:String;
		public var content:String;
		
		public static const AddTask:String = 'add_task';
		
		public function TaskEvent(type:String)
		{
			super(type, true, false);
		}
	}
}