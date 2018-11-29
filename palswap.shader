// BLAST FLOCK source files
// by TRASEVOL_DOG (https://trasevol.dog/)


varying vec2 v_vTexcoord;
varying vec4 v_vColour;

extern vec3 opal[29];
extern int swaps[29];
extern float trsps[29];

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec4 col=Texel( texture, texture_coords );
  
  int c=0;
  for (int i=0; i<29; i++){
    if (abs(col.r-opal[i].r)<0.1 && abs(col.g-opal[i].g)<0.1 && abs(col.b-opal[i].b)<0.1){
      c=i;
      break;
    }
  }
  
  float trsp=1.0-trsps[c];
  
  return vec4(opal[swaps[c]],trsp);
}