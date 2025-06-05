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

float m_frame;
float m_angle;
float4 m_color;

float rand( float2 st )
{
	return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453);
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　入出力
struct PS_INPUT
{
	float4 diffuse		: COLOR0;
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
	
	//　元テクスチャ
	float4 tex = tex2D( Tex0, In.tec0 );
	
	float2 addpos = float2( 0 + 0.01*sin(In.tec0.x*90 - m_frame/4), 0 + 0.01*sin(In.tec0.x*90 - m_frame/8) );
	float4 pix;
	
	float samp_lp	= 16;	//　サンプリング回数
	float samp_wy	= 1;	//　サンプリングway数
	float dist		= 1;	//　サンプリング間隔
	for( float i = 0; i < samp_lp; ++i ){
		for( float j = 0; j < samp_wy; ++j ){
			float angle = radians( m_angle + j * ( 360 / samp_wy ) );
			pix += tex2D( Tex0, In.tec0 + float2( (i/256*dist) * cos(angle), (i/256*dist) * sin(angle) ) + addpos );
		}
	}
	pix = pix / ( samp_lp / 2 );
	
	pix.rgb = pix.rgb / 1.5;
	tex = tex + pix;
	
	Out.col.r = tex.r * (m_color.r/255);
	Out.col.g = tex.r * (m_color.g/255);
	Out.col.b = tex.r * (m_color.b/255);
	Out.col.a = tex.a;

	Out.col *= In.diffuse;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcAura
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

