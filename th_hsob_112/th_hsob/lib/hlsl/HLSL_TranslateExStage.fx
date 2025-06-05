
//================================================================
//���ݒ�l
//Texture
sampler sampler0_ : register(s0);

//--------------------------------
float m_frame;
float m_alpha;

float rand(float2 co)
{
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}
//================================================================
//--------------------------------
//�s�N�Z���V�F�[�_���͒l
struct PS_INPUT
{
	float4 diffuse : COLOR0;  //�f�B�t���[�Y�F
	float2 texCoord : TEXCOORD0; //�e�N�X�`�����W
	float2 vPos : VPOS; //�`�����W
};

//--------------------------------
//�s�N�Z���V�F�[�_�o�͒l
struct PS_OUTPUT
{
	float4 color : COLOR0; //�o�͐F
};


//================================================================
// �V�F�[�_
//--------------------------------
//�s�N�Z���V�F�[�_
PS_OUTPUT PS( PS_INPUT In ) : COLOR0
{
	PS_OUTPUT Out;

	//--------------------------------
	//�e�N�X�`���̐F
	float4 colorTexture = tex2D(sampler0_, In.texCoord);

	//���_�f�B�t�[�Y�F
	float4 colorDiffuse = In.diffuse;

	//����
	float4 color = colorTexture * colorDiffuse;
	
	float2 seedxy;
	seedxy.x = round(In.texCoord.x*64.0f);
	seedxy.y = round(In.texCoord.y*32.0f);
	float al = m_alpha*2.0f - (1.0f - seedxy.y/32.0f);
	float cl = clamp((1.0 - al*(1.0f+rand(seedxy)*7.0f)), 0.0f, 1.0f);
//	color.rgb *= cl;
	color.a = cl;

	Out.color = color;
	return Out;
}


//================================================================
//--------------------------------
//technique
technique tcTransEx
{
	pass P0
	{
		PixelShader = compile ps_3_0 PS();
	}
}

