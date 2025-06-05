//----------------------------------------------------------------
//----------------------------------------------------------------
//　サンプラ
sampler Tex0	: register( s0 );
float m_frame;
float4 m_color;
float m_alpha;

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
	float4 pix;
	
	float samp_lp	= 16;	//　サンプリング回数
	float samp_wy	= 64;	//　サンプリングway数
	float dist		= 8;	//　サンプリング間隔
	for( float i = 0; i < samp_lp; ++i ){
		for( float j = 0; j < samp_wy; ++j ){
			float angle = radians( 45 + j * ( 360 / samp_wy ) + m_frame );
			pix += tex2D( Tex0, In.tec0 + float2( (i/256*dist) * cos(angle), (i/256*dist) * sin(angle) ) );
		}
	}
	pix = pix / ( samp_lp / 2 );
	
	Out.col.rgb = tex.rgb + pix.rgb * m_color.rgb;
	Out.col.a = tex.a + pix.a * m_alpha;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcSoftBlur
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

