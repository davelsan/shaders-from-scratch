import {
  BoxGeometry,
  Color,
  type CubeTexture,
  Mesh,
  SRGBColorSpace,
} from 'three';

import {
  shaderMaterial,
  type ShaderMaterialType,
  type State,
  WebGLView,
} from '@helpers/three';

import fragmentShader from './shader.frag.glsl';
import vertexShader from './shader.vert.glsl';
import { assets, modelColorBinding } from './State';

type Uniforms = {
  uModelColor: Color;
  uSpecMap: CubeTexture;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private geometry: BoxGeometry;
  private material: ShaderMaterial;
  private mesh: Mesh;
  private texture: CubeTexture;

  constructor(state: State) {
    super('Vector Operations', state);

    void this.init(
      this.setupAssets,
      this.setupScene,
      this.setupGeometry,
      this.setupMaterial,
      this.setupMesh,
      this.setupSubscriptions
    );

    void this.dispose(() => {
      this.material.dispose();
      this.texture.dispose();
    });
  }

  private setupAssets = async () => {
    this.texture = await assets.cubeTextures.get('sunset');
  };

  private setupScene = () => {
    this._renderer.outputColorSpace = SRGBColorSpace;

    this._scene.background = this.texture;

    this._camera.fov = 60;
    this._camera.near = 0.1;
    this._camera.far = 1000.0;
    this._camera.position.set(0, 0, 1.5);
    this._camera.updateProjectionMatrix();

    this._controls.target.set(0, 0, 0);
    this._controls.update();
  };

  private setupGeometry = () => {
    this.geometry = new BoxGeometry(1, 1, 1, 1, 1, 1);
  };

  private setupMaterial = () => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uModelColor: new Color(modelColorBinding.get()),
        uSpecMap: this.texture,
      },
    });
  };

  private setupMesh = () => {
    this.mesh = new Mesh(this.geometry, this.material);
    this._scene.add(this.mesh);
  };

  private setupSubscriptions = () => {
    this.subToAtom(modelColorBinding.atom, this.updateModelColor);
  };

  /* MODEL */

  private updateModelColor = (value: string) => {
    this.material.uModelColor = new Color(value);
  };
}
