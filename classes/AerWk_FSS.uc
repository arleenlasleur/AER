// =============================================
// fast rightmouse shield, aka fearspot shield
// trying to make combat more ranged
// =============================================

class AerWk_FSS extends FearSpot;
var aerwpn w;

function beginplay(){
        local pawn p;
        foreach touchingactors(class'pawn', p) touch(p);
}
function touch(actor other){
        local pawn p;
        local projectile pj;
        if(!other.bispawn) goto skip_nopawn;
        p = pawn(other);
        if(p==none) goto skip_nopawn;
        p.fearthisspot(self);
        skip_nopawn:
        pj = projectile(other);
        if(pj == none) return;
        if(bool(fragment(pj))) return;
        if(w !=none) w.do_shield_degrade(clamp(pj.damage>>2,10,85)); //was 3/1/25, 4/1/20
        if(!other.isa('aerprjhurtdmg')) pj.explode(other.location,normal(other.location));
}

defaultproperties{
        LifeSpan=1.4
        CollisionRadius=128
        CollisionHeight=128
        bBlockActors=true
        bProjTarget=true
}
