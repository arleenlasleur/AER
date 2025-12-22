class aercfgkey extends Decoration;
#exec texture import file="textures\skin\aercoat.bmp" name="aercoat" package="AER" group="Skin" mips=1 flags=0 btc=-2
#exec texture import file="textures\disp\aerkeybg.png" name="aerkeybg" package="AER" group="Disp" mips=1 flags=0 btc=-2

#exec mesh import mesh="aerkey_up" anivfile="models\aerkey_up_a.3d" datafile="models\aerkey_up_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerkey_up" x=0 y=0 z=0
#exec mesh sequence mesh="aerkey_up" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerkey_up" mesh="aerkey_up"
#exec meshmap scale meshmap="aerkey_up" x=0.01566 y=0.01566 z=0.03131
#exec mesh import mesh="aerkey_dn" anivfile="models\aerkey_dn_a.3d" datafile="models\aerkey_dn_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerkey_dn" x=0 y=0 z=0
#exec mesh sequence mesh="aerkey_dn" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerkey_dn" mesh="aerkey_dn"
#exec meshmap scale meshmap="aerkey_dn" x=0.01566 y=0.01566 z=0.03131
#exec mesh import mesh="aerkey_l" anivfile="models\aerkey_l_a.3d" datafile="models\aerkey_l_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerkey_l" x=0 y=0 z=0
#exec mesh sequence mesh="aerkey_l" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerkey_l" mesh="aerkey_l"
#exec meshmap scale meshmap="aerkey_l" x=0.01566 y=0.01566 z=0.03131
#exec mesh import mesh="aerkey_r" anivfile="models\aerkey_r_a.3d" datafile="models\aerkey_r_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerkey_r" x=0 y=0 z=0
#exec mesh sequence mesh="aerkey_r" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerkey_r" mesh="aerkey_r"
#exec meshmap scale meshmap="aerkey_r" x=0.01566 y=0.01566 z=0.03131
#exec mesh import mesh="aerkey_ent" anivfile="models\aerkey_ent_a.3d" datafile="models\aerkey_ent_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerkey_ent" x=0 y=0 z=0
#exec mesh sequence mesh="aerkey_ent" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerkey_ent" mesh="aerkey_ent"
#exec meshmap scale meshmap="aerkey_ent" x=0.03131 y=0.03131 z=0.06262
#exec mesh import mesh="aerkey_esc" anivfile="models\aerkey_esc_a.3d" datafile="models\aerkey_esc_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerkey_esc" x=0 y=0 z=0
#exec mesh sequence mesh="aerkey_esc" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerkey_esc" mesh="aerkey_esc"
#exec meshmap scale meshmap="aerkey_esc" x=0.01566 y=0.01566 z=0.03131

var byte aerkey_oper; // 0=unassigned 1=up, 2=dn, 3=l, 4=r, 5=esc, 6=ent
var aerwpn w;
var float last_hit_time;

function TakeDamage(int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType){
        if (bStatic || bDeleteme) return;
        Instigator = InstigatedBy;
        bBobbing = false;
        if(instigator == none) return;
        if(w == none) return;
        if(instigator.weapon != w) return;
        if(aerkey_oper == 0) return;
        if(level.timeseconds - last_hit_time < 0.1) return;
        last_hit_time = level.timeseconds;
        w.aercfg_acceptkey(aerkey_oper);
        w.aercfg_update_menu();
}

defaultproperties{
        last_hit_time=0.0
        W=None
        aerkey_oper=0
        ScaleGlow=3.0
        MultiSkins(0)=Texture'AER.Disp.aerkeybg'
        MultiSkins(1)=Texture'AER.Skin.aercoat'
        DrawType=DT_Mesh
        bStatic=False
        bUseMeshCollision=True
        bCollideWhenPlacing=True
        bStasis=False
        bCollideActors=True
        bCollideWorld=True
        bBlockActors=True
        bBlockPlayers=True
        bProjTarget=True
}
