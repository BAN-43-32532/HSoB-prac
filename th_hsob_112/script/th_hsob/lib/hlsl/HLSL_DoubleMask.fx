//----------------------------------------------------------------
//----------------------------------------------------------------
//　サンプラ
sampler Tex0	: register( s0 );
texture g_Texture;
sampler Samp0 = sampler_state
{
	Texture		= <g_Texture>;
	MipFilter	= LINEAR;	//　縮小間フィルタ（？）
	MinFilter	= LINEAR;	//　縮小フィルタ
	MagFilter	= LINEAR;	//　拡大フィルタ
	AddressU	= 1;		//　地続きのマッピングU
	AddressV	= 1;		//　地続きのマッピングV
};
texture g_Texture2;
sampler Samp1 = sampler_state
{
	Texture		= <g_Texture2>;
	MipFilter	= LINEAR;	//　縮小間フィルタ（？）
	MinFilter	= LINEAR;	//　縮小フィルタ
	MagFilter	= LINEAR;	//　拡大フィルタ
	AddressU	= 1;		//　地続きのマッピングU
	AddressV	= 1;		//　地続きのマッピングV
};
float m_frame;
float m_param;
float4 m_xyzw;

//----------------------------------------------------------------
//----------------------------------------------------------------
//　入出力
struct PS_INPUT
{
	float4 pos		: POSITION0;
	float2 tec0		: TEXCOORD0;
};
struct PS_OUTPUT
{
	float4 col	: COLOR0;
};

//----------------------------------------------------------------
//----------------------------------------------------------------
//　ピクセルシェーダ
PS_OUTPUT PS( PS_INPUT In )
{
	PS_OUTPUT Out = ( PS_OUTPUT )0;
	
	float4 tex = tex2D( Tex0, In.tec0 );
	
	float avg = (tex.r+tex.g+tex.b) / 3;
	float angle = radians( avg * 360 + m_frame );
	float2 DisPos = float2( 0.1*cos(angle), 0.1*sin(angle) );
	
	float4 mask = tex2D( Samp0, In.tec0 + float2( m_frame/250, -m_frame/500 ) + DisPos*2 );
	float4 mask2 = tex2D( Samp1, In.tec0 + float2( -m_frame/250, m_frame/500 ) + DisPos*4 );
	
	tex.r = tex.r * m_xyzw.x;
	tex.g = tex.g * m_xyzw.y;
	tex.b = tex.b * m_xyzw.z;
	
	Out.col.rgb = ( tex.rgb - mask.rgb + mask2.rgb ) * m_xyzw.w;
	Out.col.a = ( tex.a * mask.a * mask2.a ) * m_param;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcDoubleMask
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

