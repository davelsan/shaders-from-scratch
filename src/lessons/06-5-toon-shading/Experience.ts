import {
  type CubeTexture,
  IcosahedronGeometry,
  Mesh,
  SRGBColorSpace,
  Vector2,
} from 'three';
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
  private mesh: Mesh;
  private model: GLTF;
  private texture: CubeTexture;

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
        //
        uAmbientIntensity: ambientIntensityBinding.get(),
        uHemisphereIntensity: hemiIntensityBinding.get(),
        uLambertIntensity: lambertIntensityBinding.get(),
      },
    });
  };

  private setupMesh = () => {
    this.mesh = new Mesh(new IcosahedronGeometry(1, 128), this.material);
    this._scene.add(this.mesh);
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
    this.subToAtom(ambientIntensityBinding.atom, this.updateAmbientIntensity);
    this.subToAtom(hemiIntensityBinding.atom, this.updateHemisphereIntensity);
    this.subToAtom(lambertIntensityBinding.atom, this.updateLambertIntensity);
  };

  /* MODEL */

  private updateModel = (value: string) => {
    this._scene.remove(this.model.scene);
    this._scene.remove(this.mesh);

    if (value === 'suzanne') {
      this.setupModel();
    } else {
      this.setupMesh();
    }
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
