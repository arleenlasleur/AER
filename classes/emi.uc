class emi extends triggers;

function postbeginplay(){
        local vector x,y,z;
        local actor a;
        local class<actor> aclass;
        getaxes(rotation,x,y,z);
        aclass = class<actor>(DynamicLoadObject("AER.aeremipad", class'class'));
        if(aclass == none) return;
        spawn(aclass,,,location +52*x, rotation,none);
        aclass = class<actor>(DynamicLoadObject("AER.aeremirocket", class'class'));
        if(aclass == none) return;
        a = spawn(aclass,,,location +144*x,rotation,none);
        if(a != none) a.tag = tag;
        destroy();
}

defaultproperties{
        bDirectional=true
}