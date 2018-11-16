// BLAST FLOCK source files - by TRASEVOL_DOG
// /!\ do not redistribute /!\
// Download game at trasevol-dog.itch.io/blast-flock
// Ask questions to @TRASEVOL_DOG on Twitter
// Support TRASEVOL_DOG on patreon.com/trasevol_dog


varying vec2 v_vTexcoord;
varying vec4 v_vColour;

extern vec3 opal[16];
extern int swaps[16];
extern float trsps[16];

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 col=Texel( texture, texture_coords );
    
    int c=0;
    for (int i=0; i<16; i++){
     if (abs(col.r-opal[i].r)<0.1 && abs(col.g-opal[i].g)<0.1 && abs(col.b-opal[i].b)<0.1){
      c=i;
      break;
     }
    }
    
    float trsp=1.0-trsps[c];
    
    return vec4(opal[swaps[c]],trsp);
}