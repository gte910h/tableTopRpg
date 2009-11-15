package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import mx.core.UIComponent;

    /**
     * Map from tiles
     * @author Michael Langford
     */

    public class TileMap extends UIComponent
    {
        private const TILE_SIZE:Number = 10;

        private var mStringMap:String;
        private var mWidth:int;
        private var mHeight:int;

        private var mBuffer:BitmapData;
        private var mDisplay:Bitmap;


        function TileMap()
        {
            trace("Constructor");
            super();
        }

        public function SetMap(stringmap:String):void
        {
            trace("SetMap");
            mStringMap = stringmap;
            mWidth = mStringMap.indexOf('\n');
            mHeight = mStringMap.length / mWidth; //given rectangular map, this should work

            mBuffer = new BitmapData(mWidth * TILE_SIZE, mHeight * TILE_SIZE, true, 0x0000FF);

            invalidateSize();
            invalidateDisplayList();
        }

        override protected function createChildren():void
        {
            trace("createChildren");
            super.createChildren();
            mDisplay = new Bitmap();
            addChild(mDisplay);
        }

        override protected function measure():void
        {
            trace("measure");
            super.measure();

            measuredHeight = mBuffer.height;
            measuredWidth = mBuffer.width;
        }

        // Called when the display list gets invalidated
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            trace("updateDisplayList");
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            mDisplay.bitmapData = mBuffer;
        }




    }


}