import {
  Color,
  type CubeTexture,
  IcosahedronGeometry,
  Mesh,
  SRGBColorSpace,
  Vector2,
} from 'three';
import { GLTF } from 'three-stdlib';

import { ThreeState } from '@helpers/atoms';
import {
  shaderMaterial,
  type ShaderMaterialType,
  WebGLView,
} from '@helpers/three';

import fragmentShader from './shader.frag.glsl';
import vertexShader from './shader.vert.glsl';
import {
  ambientBinding,
  ambientIntensityBinding,
  assets,
  fresnelBinding,
  fresnelFalloffBinding,
  hemiBinding,
  hemiIntensityBinding,
  lambertBinding,
  lambertIntensityBinding,
  modelBinding,
  modelColorBinding,
  specEnabledBinding,
  specIntensityBinding,
  specMapBinding,
  specMapIntensityBinding,
  specTypeBinding,
} from './State';

type Uniforms = {
  uAmbient: boolean;
  uAmbientIntensity: number;
  uFresnel: boolean;
  uFresnelFalloff: number;
  uHemisphere: boolean;
  uHemisphereIntensity: number;
  uLambert: boolean;
  uLambertIntensity: number;
  uModelColor: Color;
  uSpecEnabled: boolean;
  uSpecType: 0 | 1;
  uSpecIntensity: number;
  uSpecMap: CubeTexture;
  uSpecMapEnabled: boolean;
  uSpecMapIntensity: number;
  //
  uResolution: Vector2;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private material: ShaderMaterial;
  private mesh: Mesh;
  private model: GLTF;
  private texture: CubeTexture;

  constructor(state: ThreeState) {
    super('Experience', state);

    void this.init(
      this.setupAssets,
      this.setupMaterial,
      modelBinding.get() === 'suzanne' ? this.setupModel : this.setupMesh,
      this.setupScene,
      this.setupSubscriptions
    );

    void this.dispose(() => {
      this.material.dispose();
      this.texture.dispose();
    });
  }

  private setupAssets = async () => {
    this.texture = await assets.cubeTextures.get('sunset');
    this.model = await assets.gltfs.get('suzanne');
  };

  private setupScene = ({ renderer, scene, camera, controls }: ThreeState) => {
    renderer.outputColorSpace = SRGBColorSpace;

    scene.background = this.texture;

    camera.fov = 60;
    camera.near = 0.1;
    camera.far = 1000.0;
    camera.position.set(1, 0, 5);

    controls.target.set(0, 0, 0);
    controls.update();

    camera.updateProjectionMatrix();
  };

  private setupMaterial = () => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uResolution: new Vector2(),
        //
        uAmbient: ambientBinding.get(),
        uAmbientIntensity: ambientIntensityBinding.get(),
        uFresnel: fresnelBinding.get(),
        uFresnelFalloff: fresnelFalloffBinding.get(),
        uHemisphere: hemiBinding.get(),
        uHemisphereIntensity: hemiIntensityBinding.get(),
        uLambert: lambertBinding.get(),
        uLambertIntensity: lambertIntensityBinding.get(),
        uModelColor: new Color(modelColorBinding.get()),
        uSpecEnabled: specEnabledBinding.get(),
        uSpecType: specTypeBinding.get(),
        uSpecIntensity: specIntensityBinding.get(),
        uSpecMap: this.texture,
        uSpecMapEnabled: specMapBinding.get(),
        uSpecMapIntensity: specMapIntensityBinding.get(),
      },
    });
  };

  private setupMesh = ({ scene }: ThreeState) => {
    this.mesh = new Mesh(new IcosahedronGeometry(1, 128), this.material);
    scene.add(this.mesh);
  };

  private setupModel = ({ scene }: ThreeState) => {
    this.model.scene.traverse((child) => {
      if (child instanceof Mesh) {
        child.material = this.material;
      }
    });
    scene.add(this.model.scene);
  };

  private setupSubscriptions = (state: ThreeState) => {
    modelBinding.sub((value) => {
      state.scene.remove(this.model.scene);
      state.scene.remove(this.mesh);

      if (value === 'suzanne') {
        this.setupModel(state);
      } else {
        this.setupMesh(state);
      }
    });

    ambientBinding.sub(this.updateAmbient);
    ambientIntensityBinding.sub(this.updateAmbientIntensity);

    fresnelBinding.sub(this.toggleFresnel);
    fresnelFalloffBinding.sub(this.updateFresnelFalloff);

    hemiBinding.sub(this.updateHemisphere);
    hemiIntensityBinding.sub(this.updateHemisphereIntensity);

    lambertBinding.sub(this.updateLambert);
    lambertIntensityBinding.sub(this.updateLambertIntensity);

    modelColorBinding.sub(this.updateModelColor);

    specEnabledBinding.sub(this.updateSpecPhong);
    specTypeBinding.sub(this.updateSpecType);
    specIntensityBinding.sub(this.updateSpecIntensity);

    specMapBinding.sub(this.toggleSpecMap);
    specMapIntensityBinding.sub(this.updateSpecMapIntensity);
  };

  /* MODEL */

  private updateModelColor = (value: string) => {
    this.material.uModelColor = new Color(value);
  };

  /* LIGHTING */

  private updateAmbient = (value: boolean) => {
    this.material.uAmbient = value;
  };

  private updateAmbientIntensity = (value: number) => {
    this.material.uAmbientIntensity = value;
  };

  private updateHemisphere = (value: boolean) => {
    this.material.uHemisphere = value;
  };

  private updateHemisphereIntensity = (value: number) => {
    this.material.uHemisphereIntensity = value;
  };

  private updateLambert = (value: boolean) => {
    this.material.uLambert = value;
  };

  private updateLambertIntensity = (value: number) => {
    this.material.uLambertIntensity = value;
  };

  private updateSpecPhong = (value: boolean) => {
    this.material.uSpecEnabled = value;
  };

  private updateSpecIntensity = (value: number) => {
    this.material.uSpecIntensity = value;
  };

  private toggleSpecMap = (value: boolean) => {
    this.material.uSpecMapEnabled = value;
  };

  private updateSpecType = (value: 0 | 1) => {
    this.material.uSpecType = value;
  };

  private updateSpecMapIntensity = (value: number) => {
    this.material.uSpecMapIntensity = value;
  };

  private toggleFresnel = (value: boolean) => {
    this.material.uFresnel = value;
  };

  private updateFresnelFalloff = (value: number) => {
    this.material.uFresnelFalloff = value;
  };
}
