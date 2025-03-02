import { Mesh, SRGBColorSpace, type Texture, Vector2 } from 'three';
import { GLTF } from 'three-stdlib';

import {
  shaderMaterial,
  type ShaderMaterialType,
  type State,
  WebGLView,
} from '@helpers/three';

import fragmentShader from './shader.frag.glsl';
import vertexShader from './shader.vert.glsl';
import {
  ambientBinding,
  ambientIntensityBinding,
  assets,
  hemiBinding,
  hemiIntensityBinding,
  lambertBinding,
  lambertIntensityBinding,
} from './State';

type Uniforms = {
  uAmbient: boolean;
  uAmbientIntensity: number;
  uHemisphere: boolean;
  uHemisphereIntensity: number;
  uLambert: boolean;
  uLambertIntensity: number;
  uResolution: Vector2;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private material: ShaderMaterial;
  private model: GLTF;
  private texture: Texture;

  constructor(state: State) {
    super('Vector Operations', state);

    void this.init(
      this.setupAssets,
      this.setupMaterial,
      this.setupModel,
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

  private setupScene = () => {
    this._renderer.outputColorSpace = SRGBColorSpace;

    this._scene.background = this.texture;

    this._camera.fov = 60;
    this._camera.aspect = 1920.0 / 1080.0;
    this._camera.near = 0.1;
    this._camera.far = 1000.0;
    this._camera.position.set(1, 0, 5);

    this._controls.target.set(0, 0, 0);
    this._controls.update();
  };

  private setupMaterial = () => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uResolution: new Vector2(),
        uAmbient: true,
        uAmbientIntensity: ambientIntensityBinding.get(),
        uHemisphere: true,
        uHemisphereIntensity: hemiIntensityBinding.get(),
        uLambert: true,
        uLambertIntensity: lambertIntensityBinding.get(),
      },
    });
  };

  private setupModel = () => {
    this.model.scene.traverse((child) => {
      if (child instanceof Mesh) {
        child.material = this.material;
      }
    });
    this._scene.add(this.model.scene);
  };

  private setupSubscriptions = () => {
    this.subToAtom(ambientBinding.atom, this.updateAmbient);
    this.subToAtom(ambientIntensityBinding.atom, this.updateAmbientIntensity);

    this.subToAtom(hemiBinding.atom, this.updateHemisphere);
    this.subToAtom(hemiIntensityBinding.atom, this.updateHemisphereIntensity);

    this.subToAtom(lambertBinding.atom, this.updateLambert);
    this.subToAtom(lambertIntensityBinding.atom, this.updateLambertIntensity);
  };

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
}
