//----------------------------------------------------------------
//----------------------------------------------------------------
//�@�T���v��
sampler Tex0	: register( s0 );
texture g_Texture;
sampler Samp0 = sampler_state
{
	Texture		= <g_Texture>;
	MipFilter	= LINEAR;	//�@�k���ԃt�B���^�i�H�j
	MinFilter	= LINEAR;	//�@�k���t�B���^
	MagFilter	= LINEAR;	//�@�g��t�B���^
	AddressU	= 1;		//�@�n�����̃}�b�s���OU
	AddressV	= 1;		//�@�n�����̃}�b�s���OV
};
float m_frame;
float m_param;
float4 m_xyzw;

//----------------------------------------------------------------
//----------------------------------------------------------------
//�@���o��
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
//�@�s�N�Z���V�F�[�_
PS_OUTPUT PS( PS_INPUT In )
{
	PS_OUTPUT Out = ( PS_OUTPUT )0;
	
	float4 tex = tex2D( Tex0, In.tec0 );
	float4 mask = tex2D( Samp0, In.tec0 * 2 + float2( m_frame/500, m_frame/100 ) );
	
	tex.r = tex.r * m_xyzw.x;
	tex.g = tex.g * m_xyzw.y;
	tex.b = tex.b * m_xyzw.z;
	
	Out.col.rgb = tex.rgb * mask.rgb;
	Out.col.a = tex.a + (tex.a * mask.a * m_param) / 2;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//�@�e�N�j�b�N
technique tcFire
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

