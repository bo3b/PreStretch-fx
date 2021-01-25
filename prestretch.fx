// Prestretch.fx
//
// Reshade.fx shader to stretch the backbuffer across a double width texture.


#include "ReShade.fxh"

namespace prestretch
{

/*=============================================================================
	Textures, Samplers, Globals
=============================================================================*/

texture LeftTex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

sampler SamplerLeft
	{
		Texture = LeftTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

texture RightTex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };

sampler SamplerRight
	{
		Texture = RightTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

/*=============================================================================
	Vertex Shader
=============================================================================*/
// Some gotchas here.
//  The position output is in game dimensions Buffer_Width Buffer_Height
//  The texcoord output is in uv format 0..1


// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

/*=============================================================================
	Pixel Shaders
=============================================================================*/

// Gotchas:
//  The input parameters must exactly match the VS inputs.  Even if unused,
//  they must be there, or it silently fails.
//  The SV_Targets must start at 0, or are silently ignored.

void PS_CopyLR(in float4 vpos : SV_Position, in float2 texcoord : TEXCOORD, 
			   out float4 Left : SV_Target0, out float4 Right : SV_Target1)
{
	// float2 stretchXY;
	// stretchXY.x = vpos.x; // / 2;
	// stretchXY.y = vpos.y;
	
	Left = tex2D(ReShade::BackBuffer, texcoord);
	Right = tex2D(ReShade::BackBuffer, texcoord);
}

float4 PS_LR_Out(in float4 vpos : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
	// float2 stretchXY;
	// stretchXY.x = texcoord.x / 2;
	// stretchXY.y = texcoord.y;
	
	// return tex2D(ReShade::BackBuffer, stretchXY);

	if (texcoord.x > 0.5)
		return tex2D(SamplerRight, texcoord);
	else
		return tex2D(SamplerLeft, texcoord);
}

void PS_StretchDebug(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 doubled : SV_Target0)
{
	float2 stretchXY;
	stretchXY.x = texcoord.x;
	stretchXY.y = texcoord.y;
	
	doubled = tex2D(ReShade::BackBuffer, stretchXY);
}


/*=============================================================================
	Techniques
=============================================================================*/

technique Prestretch <ui_tooltip = "Stretch to double width."; >
{
	pass StretchPassDebug
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_StretchDebug;
	}

	// pass StretchPass
	// {
		// VertexShader = PostProcessVS;
		// PixelShader = PS_CopyLR;
		// RenderTarget0 = LeftTex;
		// RenderTarget1 = RightTex;
	// }

	// pass BackBuffer
	// {
		// VertexShader = PostProcessVS;
		// PixelShader = PS_LR_Out;
	// }
}

}
