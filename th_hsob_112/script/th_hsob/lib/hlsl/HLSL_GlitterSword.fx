
//================================================================
//���ݒ�l
//Texture
sampler sampler0_ : register(s0);

//--------------------------------
float m_position;
float m_power;
const float PI = 3.141592653589f;

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
	
	float seed = (In.texCoord.x+m_position*2.0f)/2.0f * PI;
//	float seed = (In.texCoord.x+In.texCoord.y+m_position*2.0f)/2.0f * PI;
	float light = (pow(sin(seed),5) + 0.5f)/1.5f * m_power;
	color.rgb += light;

	Out.color = color;
	return Out;
}


//================================================================
//--------------------------------
//technique
technique tcSword
{
	pass P0
	{
		PixelShader = compile ps_3_0 PS();
	}
}

