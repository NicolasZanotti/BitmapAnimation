package com.stoletheshow.display 
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * This class spreads out the creation of a bitmap animation over a predefined period of time.
	 * 
	 * Usage:
	 * <pre>
	 * 		var bitmapAnimation:DelayedBitmapAnimation = new DelayedBitmapAnimation();
	 * 		bitmapAnimation.pauseBetweenIterations = 20;
	 *		bitmapAnimation.draw(movieClip);
	 *		addChild(bitmapAnimation);
	 * </pre>
	 * 
	 * @author Nicolas Schudel
	 * @langversion 3.0
	 * @playerversion Flash 9
	 * @version 20091115 Initial Vesion.
	 * @version 20100410 progressPercent added by Yu-Chung Chen.
	 * @version 20100501 Renamed progressPercent to percentComplete (like the ProgressBar component) and changed values to range from 0 to 100.
	 * @see BitmapAnimation
	 */
	public class DelayedBitmapAnimation extends BitmapAnimation 
	{
		/**
		 * The amount of time in milliseconds to wait before processing the next bitmap.
		 */
		protected var _timer:Timer,
					_bmpd:BitmapData,
					_source:MovieClip,
					_transparent:Boolean,
					_fillColor:int,
					_percentComplete:uint = 0;
		public var	pauseBetweenIterations:int = 10;

		public function DelayedBitmapAnimation(pauseBetweenIterations:int = 10)
		{
			this.pauseBetweenIterations = pauseBetweenIterations;
			super(null);
		}

		protected function onTimer(event:TimerEvent):void
		{
			// This is a similar operation to the parent classes parse method.
			_source.gotoAndStop(_timer.currentCount);
			
			try 
			{
				_bmpd = new BitmapData(_source.width, _source.height, _transparent, _fillColor);
				_bmpd.draw(_source);
			}
			catch (error:Error) 
			{
				trace(error.message);
				return;
			}
			
			_bitmapDatas[_timer.currentCount - 1] = _bmpd;
			
			if (_timer.currentCount - 1 == _bitmapDatasLength) 
			{
				_percentComplete = 100;
				
				// Stop the loop and clean up.
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTimer, false);
				_timer = null;
				_bmpd.dispose();
				_bmpd = null;
				_source = null;
				_fillColor = 0;
				
				// Draw the first frame.
				onEnterFrame();
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else 
			{
				_percentComplete = _bitmapDatas.length / (_source.totalFrames + 1) * 100;
			}
		}

		override public function draw(mc:MovieClip, transparent:Boolean = false, fillColor:int = 0x000000):void 
		{
			_bitmapDatas = [];
			_source = mc;
			_bitmapDatasLength = _source.totalFrames;
			_transparent = transparent;
			_fillColor = fillColor;
			
			_timer = new Timer(pauseBetweenIterations);
			_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			_timer.start();
		}

		/**
		 * Gets a number between 0 and 100 that indicates the percentage of data that has been drawn.
		 */
		public function get percentComplete():Number 
		{ 
			return _percentComplete; 
		}
	}
}
