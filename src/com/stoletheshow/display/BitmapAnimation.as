package com.stoletheshow.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * This class converts a MovieClip into a bitmap sequence. Optimal for decompressing Videos or complex vector animations.
	 * 
	 * Usage:
	 * <pre>
	 * 		var bitmapAnimation:BitmapAnimation = new BitmapAnimation();
	 *		bitmapAnimation.draw(movieClip);
	 *		addChild(bitmapAnimation);
	 * </pre>
	 * 
	 * @author Nicolas Schudel
	 * @langversion 3.0
	 * @playerversion Flash 9
	 * @param Array containing BitmapData
	 * @version 20090612 Initial version named VideoClip. Created at Maxomedia, www.maxomedia.com
	 * @version 20091105 Fixed a bug where the video is not updated when a bitmap sequence is passed in the constructor.
	 * @version 20091115 Added dispose method.
	 * @version 20100410 By Yu-Chung Chen. Added totalFrames and currentFrame getters. play() updates the _index so currentFrame works properly.
	 */
	public class BitmapAnimation extends Sprite
	{
		protected var	_bitmapDatas:Array, 
						_filters:Array, 
						_index:int = -1, 
						_bitmapDatasLength:int,
						_isAnimating:Boolean = false,
						_isStoped:Boolean = false;
		public var		bitmap:Bitmap = new Bitmap();

		public function BitmapAnimation(bitmapDatas:Array = null)
		{
			if (bitmapDatas) 
			{
				_bitmapDatas = bitmapDatas;
				_bitmapDatasLength = bitmapDatas.length;
			}
			
			addChild(bitmap);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}

		protected function onAddedToStage(event:Event):void
		{
			_isStoped ? gotoAndStop(1) : gotoAndPlay(1);
		}

		protected function onRemovedFromStage(event:Event):void
		{
			if (!_isStoped) stop();
		}

		protected function onEnterFrame(event:Event = null):void
		{
			_index++;
			_index = _index % _bitmapDatasLength;
			// Copypixels will decreas performance by ca. 5%.
			bitmap.bitmapData = _bitmapDatas[_index];
		}

		override public function set filters(filters:Array):void 
		{
			_filters = filters;
			
			if (!_bitmapDatasLength) return;
			
			var filter:BitmapFilter;
			var bitmap:BitmapData;
			var sourceRect:Rectangle = new Rectangle(0, 0, (_bitmapDatas[0] as BitmapData).width, (_bitmapDatas[0] as BitmapData).height);
			var destPoint:Point = new Point(0, 0);
			
			for each (filter in filters) 
			{
				for each (bitmap in _bitmapDatas) 
				{
					try 
					{
						bitmap.applyFilter(bitmap, sourceRect, destPoint, filter);
					}
					catch(error:Error)
					{
						// Probably best to just keep going rather than throw an error.
						trace(error.message);
					}
				}
			}
		}

		override public function get filters():Array 
		{
			return _filters;
		}

		override public function set cacheAsBitmap(value:Boolean):void 
		{
			// Enabling cacheAsBitmap will result in a huge performance hit.
		}

		override public function get cacheAsBitmap():Boolean 
		{
			return super.cacheAsBitmap;
		}

		public function draw(mc:MovieClip, transparent:Boolean = false, fillColor:int = 0x000000):void 
		{
			_bitmapDatas = [];
			_bitmapDatasLength = mc.totalFrames;
			var bmpd:BitmapData;
			for (var i:int = 0;i < _bitmapDatasLength;i++) 
			{
				mc.gotoAndStop(i + 1);
				try 
				{
					// Flash may throw an error if it can't keep up.
					// If multiple BitmapAnimations use the same basis, pass the bitmap array in the constructor after processing the first.
					bmpd = new BitmapData(mc.width, mc.height, transparent, fillColor);
					bmpd.draw(mc);
				}
				catch (error:Error) 
				{
					trace(error.message);
					return;
				}
				_bitmapDatas[i] = bmpd;
			}
		}

		public function get bitmapSequence():Array 
		{
			return _bitmapDatas;
		}

		public function gotoAndStop(frame:int):void 
		{
			if (_isAnimating) stop();
			bitmap.bitmapData = _bitmapDatas[frame - 1];
			_index = frame;
		}

		public function gotoAndPlay(frame:int):void 
		{
			if (_isAnimating) stop();
			// -1 for array, -1 because it gets added again onEnterframe
			_index = frame - 2;
			play();
		}

		public function nextFrame():void 
		{
			onEnterFrame();
		}

		public function prevFrame():void 
		{
			_index--;
			if (_index < 0) _index = _bitmapDatasLength - 1;
			bitmap.bitmapData = _bitmapDatas[_index];
		}

		public function play():void 
		{
			_isStoped = false;
			if (!_bitmapDatasLength || _isAnimating) return;
			if (!bitmap.bitmapData) bitmap.bitmapData = _bitmapDatas[0];
			_isAnimating = true;
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}

		public function stop():void 
		{
			_isStoped = true;
			if (!_isAnimating) return;
			_isAnimating = false;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame, false);
		}

		public function dispose():void 
		{
			stop();
			removeChild(bitmap);
			bitmap = null;
			_bitmapDatas = null;
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false);
		}

		public function get totalFrames():int
		{
			return _bitmapDatasLength;
		}

		public function get currentFrame():int
		{
			return _index;
		}
		
		public function get isAnimating():Boolean
		{
			return _isAnimating;
		}
		
		public function get isStoped():Boolean
		{
			return _isStoped;
		}
	}
}