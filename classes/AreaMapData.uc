class AreaMapData extends Info abstract;
// LIMITATIONS:   1. ALL textures must have same SHR_factor due to output cycle simplicity
//                2. 63 textures max. More exceeds static array bounds (1 tex = 4 bytes).
//#exec texture import file="textures\icon_areamap.png" name="icon_areamap" package="AER" mips=1 flags=0 btc=-2

var() texture MapTex[63]; // name tex
var() int AlignX[63],     // align
          AlignY[63],
          AreaZ[63];
var() byte SHR_factor;    // bitshift, default >>4 equ 1px=16uu
var() float AreaHght;     // AreaZ coverage if other than 128.0

defaultproperties{
//  Texture=texture'AER.icon_areamap' // must be never placed in unrealed
  SHR_factor=4
}