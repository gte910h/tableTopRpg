package 
{
    import mx.core.UIComponent;
    
    /**
     * Map from tiles
     * @author Michael Langford
     */
    
    public class tilemap extends UIComponent 
    {
        private var _stringmap:String;
        private var _width:int;
        private var _height:int;
        
        function tilemap(stringmap:String)
        {
            _stringmap = stringmap;
            _width = _stringmap.indexOf('\n');
            _height = _stringmap.length / _width; //given rectangular map, this should work
            
             trace(_height);
             trace(_width);
             trace("for")
             trace(_stringmap);
        }
        
    }
    
}