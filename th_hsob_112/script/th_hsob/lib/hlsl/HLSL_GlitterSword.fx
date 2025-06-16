
//================================================================
//大域設定値
//Texture
sampler sampler0_ : register(s0);

//--------------------------------
float m_position;
float m_power;
const float PI = 3.141592653589f;

//================================================================
//--------------------------------
//ピクセルシェーダ入力値
struct PS_INPUT
{
	float4 diffuse : COLOR0;  //ディフューズ色
	float2 texCoord : TEXCOORD0; //テクスチャ座標
	float2 vPos : VPOS; //描画先座標
};

//--------------------------------
//ピクセルシェーダ出力値
struct PS_OUTPUT
{
	float4 color : COLOR0; //出力色
};


//================================================================
// シェーダ
//--------------------------------
//ピクセルシェーダ
PS_OUTPUT PS( PS_INPUT In ) : COLOR0
{
	PS_OUTPUT Out;

	//--------------------------------
	//テクスチャの色
	float4 colorTexture = tex2D(sampler0_, In.texCoord);

	//頂点ディフーズ色
	float4 colorDiffuse = In.diffuse;

	//合成
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

