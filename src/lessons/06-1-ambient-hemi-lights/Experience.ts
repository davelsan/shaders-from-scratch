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
import { ambientBinding, assets, hemiBinding } from './State';

type Uniforms = {
  uAmbient: boolean;
  uHemisphere: boolean;
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
    const sunset = assets.cubeTexturesFamily('sunset');
    this.texture = await this._state.store.get(sunset);

    const suzanne = assets.gltfsFamily('suzanne');
    this.model = await this._state.store.get(suzanne);
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
        uHemisphere: true,
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
    this.subToAtom(ambientBinding, this.updateAmbient);
    this.subToAtom(hemiBinding, this.updateHemisphere);
  };

  private updateAmbient = (value: boolean) => {
    this.material.uAmbient = value;
  };

  private updateHemisphere = (value: boolean) => {
    this.material.uHemisphere = value;
  };
}
