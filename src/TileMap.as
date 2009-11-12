package
{
    import mx.core.UIComponent;

    /**
     * Map from tiles
     * @author Michael Langford
     */

    public class TileMap extends UIComponent
    {
        private var mStringMap:String;
        private var mWidth:int;
        private var mHeight:int;

        function TileMap(stringmap:String)
        {
            mStringMap = stringmap;
            mWidth = mStringMap.indexOf('\n');
            mHeight = mStringMap.length / mWidth; //given rectangular map, this should work

             trace(mHeight);
             trace(mWidth);
             trace("for")
             trace(mStringMap);
        }

    }

}