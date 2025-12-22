class aeremiexplode extends effects;
var float animtimer;
#exec texture import file="textures\skin\aerburst.pcx" name="aerburst" package="AER" group="Skin" mips=1 flags=0 btc=-2
#exec mesh import mesh="aeremiblast" anivfile="Models\aeremiblast_a.3d" datafile="Models\aeremiblast_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aeremiblast" x=0 y=0 z=0
#exec mesh sequence mesh="aeremiblast" seq=All startframe=0 numframes=1
#exec meshmap new meshmap="aeremiblast" mesh="aeremiblast"
#exec meshmap scale meshmap="aeremiblast" x=2.00391 y=2.00391 z=4.00783

function tick(float f){
   if(animtimer > 0){
      animtimer-=f;
      return;
   }
   animtimer = 0.015;
   if(ambientglow>0){
      ambientglow -= 1;
      scaleglow -= 1;
      drawscale = 0.0039 * (255-ambientglow);
   } else destroy();
}

defaultproperties{
  DrawType=DT_Mesh
  Drawscale=0.0039
  ambientglow=254
  ScaleGlow=254
  Mesh=Mesh'aeremiblast'
  bCollideWhenPlacing=false
  bCollideActors=false
  bCollideWorld=false
  bBlockActors=false
  bBlockPlayers=false
  CollisionRadius=1.00000
  CollisionHeight=1.00000
  MultiSkins(0)=Texture'AER.Skin.aerburst'
}
