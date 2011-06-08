package  
{
	import com.stoletheshow.display.BitmapAnimation;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;

	/**
	 * @author Nicolas Schudel
	 */
	public class Main extends Sprite 
	{
		public var cursor:MovieClip;
		public var bitmapAnimation:BitmapAnimation;
		private var _previousMouseX:Number;

		public function Main()
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			cursor.stop();
			cursor.mouseChildren = cursor.mouseEnabled = false;
			Mouse.hide();
			
			bitmapAnimation = new BitmapAnimation();
			bitmapAnimation.draw(new (getDefinitionByName("Loop") as Class)() as MovieClip);
			bitmapAnimation.y = -80;
			bitmapAnimation.stop();
			addChildAt(bitmapAnimation, 0);
		}

		private function onMouseDown(event:MouseEvent):void 
		{
			cursor.gotoAndStop(2);
		}

		private function onMouseUp(event:MouseEvent):void 
		{
			cursor.gotoAndStop(1);
		}

		private function onMouseLeave(event:Event):void 
		{
			cursor.visible = false;
		}

		private function onMouseMove(event:MouseEvent):void 
		{
			event.updateAfterEvent();
			
			cursor.visible = true;
			cursor.x = event.stageX;
			cursor.y = event.stageY;
			
			if (cursor.currentFrame == 2) 
			{
				if (event.stageX > _previousMouseX) bitmapAnimation.prevFrame();
				else if (event.stageX < _previousMouseX) bitmapAnimation.nextFrame();
				_previousMouseX = event.stageX;
			}
		}
	}
}