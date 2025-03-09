import {
  BoxGeometry,
  Color,
  type CubeTexture,
  Mesh,
  SRGBColorSpace,
} from 'three';

import { ThreeState } from '@helpers/atoms';
import {
  shaderMaterial,
  type ShaderMaterialType,
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

  constructor(state: ThreeState) {
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

  private setupScene = ({ renderer, scene, camera, controls }: ThreeState) => {
    renderer.outputColorSpace = SRGBColorSpace;

    scene.background = this.texture;

    camera.fov = 60;
    camera.near = 0.1;
    camera.far = 1000.0;
    camera.position.set(0, 0, 1.5);

    controls.target.set(0, 0, 0);
    controls.update();

    camera.updateProjectionMatrix();
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

  private setupMesh = ({ scene }: ThreeState) => {
    this.mesh = new Mesh(this.geometry, this.material);
    scene.add(this.mesh);
  };

  private setupSubscriptions = () => {
    modelColorBinding.sub(this.updateModelColor);
  };

  /* MODEL */

  private updateModelColor = (value: string) => {
    this.material.uModelColor = new Color(value);
  };
}
