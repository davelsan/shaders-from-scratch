import {
  Color,
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

  constructor(state: State) {
    super('Vector Operations', state);

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
    this.subToAtom(modelBinding.atom, this.updateModel);

    this.subToAtom(ambientBinding.atom, this.updateAmbient);
    this.subToAtom(ambientIntensityBinding.atom, this.updateAmbientIntensity);

    this.subToAtom(fresnelBinding.atom, this.toggleFresnel);
    this.subToAtom(fresnelFalloffBinding.atom, this.updateFresnelFalloff);

    this.subToAtom(hemiBinding.atom, this.updateHemisphere);
    this.subToAtom(hemiIntensityBinding.atom, this.updateHemisphereIntensity);

    this.subToAtom(lambertBinding.atom, this.updateLambert);
    this.subToAtom(lambertIntensityBinding.atom, this.updateLambertIntensity);

    this.subToAtom(modelColorBinding.atom, this.updateModelColor);

    this.subToAtom(specEnabledBinding.atom, this.updateSpecPhong);
    this.subToAtom(specTypeBinding.atom, this.updateSpecType);
    this.subToAtom(specIntensityBinding.atom, this.updateSpecIntensity);

    this.subToAtom(specMapBinding.atom, this.toggleSpecMap);
    this.subToAtom(specMapIntensityBinding.atom, this.updateSpecMapIntensity);
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
