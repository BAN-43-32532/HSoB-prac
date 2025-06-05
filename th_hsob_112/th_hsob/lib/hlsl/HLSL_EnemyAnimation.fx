//----------------------------------------------------------------
//----------------------------------------------------------------
//　HSV変換
float4 RGB2HSV( float4 v_rgb )
{
	float4 ahsv;
	
	float RGBmax = max( v_rgb.r, max( v_rgb.g, v_rgb.b ) );
	float RGBmin = min( v_rgb.r, min( v_rgb.g, v_rgb.b ) );
	float delta = RGBmax - RGBmin;
	
	//　A:α値
	ahsv.a = v_rgb.a;
	//　V:明度
	ahsv.b = RGBmax;
	//　S:彩度
	ahsv.g = ( RGBmax != 0.0 ) ? delta / RGBmax : 0.0;
	//　H:色相
	ahsv.r = ( v_rgb.r == RGBmax ) ? (v_rgb.g-v_rgb.b)/delta :
		( v_rgb.g == RGBmax ) ? 2+(v_rgb.b-v_rgb.r)/delta : 4+(v_rgb.r-v_rgb.g)/delta ;
	ahsv.r /= 6.0;
	ahsv.r += ( ahsv.r < 0 ) ? 1.0 : 0 ;
	
	return ahsv;
}

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
float4 m_color;
float4 m_pos;

float2 m_rtSize;
float2 m_texSize;

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
	
	//　元テクスチャ
	float4 tex = tex2D( Tex0, In.tec0 );
	//　RGB->HSV
	float4 hsv = RGB2HSV( tex );
	//　揺らぎ
	float ang = radians( hsv.r );
	float4 sam = tex2D( Samp0, In.tec0 + float2( 0.005 * cos( ang ), 0.005 * sin( ang ) ) );
	
	/*
	//　拡縮値
	float2 m_cvTex2Rt = m_rtSize / m_texSize;
	//　座標連携
	float2 rtp = m_pos * ( 1 / m_rtSize );
	//　中央補正
	float2 cen = m_texSize / 2 * ( 1 / m_rtSize );
	//　サンプリング
	float4 samp = tex2D( Samp0, In.tec0 / m_cvTex2Rt + rtp - cen );
	*/
	
	Out.col.rgb = tex.rgb * sam.rgb;
	Out.col.a = tex.a;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcEnemyAnimation
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

