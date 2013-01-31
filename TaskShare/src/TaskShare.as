package
{
	import com.bit101.components.AirWindow;
	import com.isflash.events.TaskEvent;
	import com.isflash.net.TaskServer;
	import com.isflash.ui.CommitTaskUI;
	import com.isflash.ui.LoginUI;
	import com.isflash.ui.TaskCell;

	[SWF(width='800',height='600')]
	public class TaskShare extends AirWindow
	{
		private var loginUI:LoginUI = new LoginUI();
		private var commitTaskUI:CommitTaskUI = new CommitTaskUI();
		private var server:TaskServer;
		private var user:String;
		private var taskManager:Array = [];
		
		public function TaskShare()
		{
			super(stage.nativeWindow,'任务分享系统');
			
			this.addEventListener(TaskEvent.Login,onLogin);
			this.addEventListener(TaskEvent.CommitTask,commitTask);
			commitTaskUI.x = 250;
			commitTaskUI.y = 370;
			this.addChild(commitTaskUI);
			this.addChild(loginUI);
		}
		
		private function onLogin(e:TaskEvent):void
		{
			if(e.userName == 'cz' || e.userName == 'zs'){
				user = e.userName;
				if(loginUI.parent){
					loginUI.parent.removeChild(loginUI);
				}
				server = new TaskServer(user);
				server.addEventListener(TaskEvent.AddTask,addTask);
			}
		}
		
		private function addTask(e:TaskEvent):void
		{
			var task:TaskCell = new TaskCell(e.title,e.content);
			task.y = taskManager.length * 260;
			this.addChild(task);
			
			taskManager.push(task);
		}
		
		private function commitTask(e:TaskEvent):void
		{
			server.commitTask(e.title,e.content);
		}
	}
}