// Prestretch.fx
//
// Reshade.fx shader to stretch the backbuffer across two destination textures.


/*=============================================================================
	Textures, Samplers, Globals
=============================================================================*/

texture BackBufferTex : COLOR;
sampler sBackBuffer { Texture = BackBufferTex; };

texture DepthBufferTex : DEPTH;
sampler sDepthBuffer { Texture = DepthBufferTex; };


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
//  SV_Position output is a required parameter, otherwise the shader fails.


// Vertex shader generating a triangle covering the entire screen
void VS_PostProcess(in uint id : SV_VertexID, 
				   out float2 texcoord : TEXCOORD, out float4 position : SV_Position)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

/*=============================================================================
Pixel Shaders
=============================================================================*/

// Gotchas:
//  The input parameters must exactly match the order of the VS outputs so that 
//  the HLSL registers will match.
//  The SV_Targets must start at SV_Target0, or are silently ignored.

void PS_CopyLR(in float2 texcoord : TEXCOORD, 
			   out float4 Left : SV_Target0, out float4 Right : SV_Target1)
{
	// float2 stretchXY;
	// stretchXY.x = vpos.x; // / 2;
	// stretchXY.y = vpos.y;
	
	Left = tex2D(sBackBuffer, texcoord);
	Right = tex2D(sBackBuffer, texcoord);
}

/*=============================================================================
	Techniques
=============================================================================*/

technique Prestretch <ui_tooltip = "Stretch to double width."; >
{
	pass StretchPass
	{
		VertexShader = VS_PostProcess;
		PixelShader = PS_CopyLR;
		RenderTarget0 = LeftTex;
		RenderTarget1 = RightTex;
	}
}
