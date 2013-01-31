package com.isflash.net
{
	import com.isflash.events.TaskEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;

	public class TaskServer extends EventDispatcher
	{
		private const SERVER:String = "rtmfp://p2p.rtmfp.net/"; 
		private const DEVKEY:String = "875e22100d64df1ccc1c6289-8d38770178c8"; 
		private var nc:NetConnection;
		private var netGroup:NetGroup;
		private var user:String;
		
		public function TaskServer(user:String)
		{
			this.user = user;
			this.connect();
		}
		
		private function connect():void{ 
			nc = new NetConnection(); 
			nc.addEventListener(NetStatusEvent.NET_STATUS,netStatus); 
			nc.connect(SERVER+DEVKEY); 
		}    
		
		internal function netStatus(evt:NetStatusEvent):void{ 
			switch(evt.info.code){ 
				case "NetConnection.Connect.Success":
					setupGroup(); 
					break; 
				case "NetGroup.Connect.Success":
					break;
				case "NetGroup.Posting.Notify":
					praseMessage(evt.info.message); 
					break;
			} 
		} 
		
		private function setupGroup():void{ 
			var gorupspec:GroupSpecifier = new GroupSpecifier("task"); 
			gorupspec.serverChannelEnabled = true; 
			gorupspec.postingEnabled = true; 
			netGroup = new NetGroup(nc,gorupspec.groupspecWithAuthorizations()); 
			netGroup.addEventListener(NetStatusEvent.NET_STATUS,netStatus); 
		} 
		
		private function sendMessage(cmd:String,title:String,content:String=null):void{ 
			var message:Object = new Object(); 
			message.sender = netGroup.convertPeerIDToGroupAddress(nc.nearID); 
			message.user = this.user;
			message.cmd = cmd;
			message.title = title;
			if(content){
				message.content = content;
			}
			netGroup.post(message); 
			praseMessage(message); 
		} 
		
		private function praseMessage(data:Object):void
		{
			switch(data.cmd){
				case 'commitTask':
					var e:TaskEvent = new TaskEvent(TaskEvent.AddTask);
					e.title = data.title;
					e.content = data.content;
					this.dispatchEvent(e);
					break;
				case 'acceptTask':
					break;
				case 'delTask':
					break;
			}
		}
		/**
		 * 添加任务 
		 * @param title
		 * @param content
		 * 
		 */		
		public function commitTask(title:String,content:String):void
		{
			sendMessage('commitTask',title,content);
		}
		/**
		 * 领取任务 
		 * @param title
		 * 
		 */		
		public function acceptTask(title:String):void
		{
			sendMessage('acceptTask',title);
		}
		/**
		 * 完成任务 
		 * 
		 */		
		public function delTask(title:String):void
		{
			sendMessage('delTask',title);
		}
	}
}