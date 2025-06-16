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
float m_angle;
float4 m_color;

float rand( float2 st )
{
	return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453);
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//�@���o��
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
//�@�s�N�Z���V�F�[�_
PS_OUTPUT PS( PS_INPUT In )
{
	PS_OUTPUT Out = ( PS_OUTPUT )0;
	
	//�@���e�N�X�`��
	float4 tex = tex2D( Tex0, In.tec0 );
	
	float2 addpos = float2( 0 + 0.01*sin(In.tec0.x*90 - m_frame/4), 0 + 0.01*sin(In.tec0.x*90 - m_frame/8) );
	float4 pix;
	
	float samp_lp	= 16;	//�@�T���v�����O��
	float samp_wy	= 1;	//�@�T���v�����Oway��
	float dist		= 1;	//�@�T���v�����O�Ԋu
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
//�@�e�N�j�b�N
technique tcAura
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

