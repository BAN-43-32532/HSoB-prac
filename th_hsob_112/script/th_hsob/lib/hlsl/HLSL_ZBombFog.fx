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
float4 m_xyzw;
float m_param;

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
	float avg = (tex.r+tex.g+tex.b) / 3;
	float angle = radians( avg * 360 + m_frame );
	
	float4 msk = tex2D( Samp0, In.tec0 / float2( 4, 1 ) + float2( 0.1*cos(angle), 0.1*sin(angle) ) );
	float4 mskCl;
	
	mskCl.r = msk.r * m_xyzw.x;
	mskCl.g = msk.g * m_xyzw.y;
	mskCl.b = msk.b * m_xyzw.z;
	
	Out.col.rgb = msk.rgb/8 + mskCl.rgb;
	Out.col.a = tex.a * m_param;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//�@�e�N�j�b�N
technique tcZBombFog
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

