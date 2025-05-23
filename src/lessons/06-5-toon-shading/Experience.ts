import { type CubeTexture, Mesh, SRGBColorSpace, Vector2 } from 'three';
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
  ambientIntensityBinding,
  assets,
  hemiIntensityBinding,
  lambertIntensityBinding,
} from './State';

type Uniforms = {
  uAmbientIntensity: number;
  uHemisphereIntensity: number;
  uLambertIntensity: number;
  //
  uResolution: Vector2;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private material: ShaderMaterial;
  private model: GLTF;
  private texture: CubeTexture;

  constructor(state: ThreeState) {
    super('Experience', state);

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

  private setupScene = ({ renderer, scene, camera, controls }: ThreeState) => {
    renderer.outputColorSpace = SRGBColorSpace;

    scene.background = this.texture;

    camera.fov = 60;
    camera.near = 0.1;
    camera.far = 1000.0;
    camera.position.set(1, 0, 3);

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
        uAmbientIntensity: ambientIntensityBinding.get(),
        uHemisphereIntensity: hemiIntensityBinding.get(),
        uLambertIntensity: lambertIntensityBinding.get(),
      },
    });
  };

  private setupModel = ({ scene }: ThreeState) => {
    this.model.scene.traverse((child) => {
      if (child instanceof Mesh) {
        child.material = this.material;
      }
    });
    scene.add(this.model.scene);
  };

  private setupSubscriptions = () => {
    ambientIntensityBinding.sub(this.updateAmbientIntensity);
    hemiIntensityBinding.sub(this.updateHemisphereIntensity);
    lambertIntensityBinding.sub(this.updateLambertIntensity);
  };

  /* LIGHTING */

  private updateAmbientIntensity = (value: number) => {
    this.material.uAmbientIntensity = value;
  };

  private updateHemisphereIntensity = (value: number) => {
    this.material.uHemisphereIntensity = value;
  };

  private updateLambertIntensity = (value: number) => {
    this.material.uLambertIntensity = value;
  };
}
