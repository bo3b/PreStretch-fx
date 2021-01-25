// Prestretch.fx
//
// Reshade.fx shader to stretch the backbuffer across a double width texture.


#include "ReShade.fxh"

namespace prestretch
{

float4 PS_Stretch(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float2 stretchXY;
	stretchXY.x = texcoord.x / 2;
	stretchXY.y = texcoord.y;
	
	return tex2D(ReShade::BackBuffer, stretchXY);
}

technique Prestretch <ui_tooltip = "Stretch to double width."; >
{
	pass StretchPass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_Stretch;
	}
}

}
