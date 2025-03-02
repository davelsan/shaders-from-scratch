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
  specMapBinding,
  specMapIntensityBinding,
  specPhongBinding,
  specPhongIntensityBinding,
} from './State';

type Uniforms = {
  uAmbient: boolean;
  uAmbientIntensity: number;
  uHemisphere: boolean;
  uHemisphereIntensity: number;
  uLambert: boolean;
  uLambertIntensity: number;
  uSpecPhong: boolean;
  uSpecPhongIntensity: number;
  uSpecMap: CubeTexture;
  uSpecMapEnabled: boolean;
  uSpecMapIntensity: number;
  uFresnel: boolean;
  uFresnelFalloff: number;
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
        uHemisphere: hemiBinding.get(),
        uHemisphereIntensity: hemiIntensityBinding.get(),
        uLambert: lambertBinding.get(),
        uLambertIntensity: lambertIntensityBinding.get(),
        uSpecPhong: specPhongBinding.get(),
        uSpecPhongIntensity: specPhongIntensityBinding.get(),
        uSpecMap: this.texture,
        uSpecMapEnabled: specMapBinding.get(),
        uSpecMapIntensity: specMapIntensityBinding.get(),
        uFresnel: fresnelBinding.get(),
        uFresnelFalloff: fresnelFalloffBinding.get(),
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

    this.subToAtom(hemiBinding.atom, this.updateHemisphere);
    this.subToAtom(hemiIntensityBinding.atom, this.updateHemisphereIntensity);

    this.subToAtom(lambertBinding.atom, this.updateLambert);
    this.subToAtom(lambertIntensityBinding.atom, this.updateLambertIntensity);

    this.subToAtom(specPhongBinding.atom, this.updateSpecPhong);
    this.subToAtom(
      specPhongIntensityBinding.atom,
      this.updateSpecPhongIntensity
    );

    this.subToAtom(specMapBinding.atom, this.toggleSpecMap);
    this.subToAtom(specMapIntensityBinding.atom, this.updateSpecMapIntensity);

    this.subToAtom(fresnelBinding.atom, this.toggleFresnel);
    this.subToAtom(fresnelFalloffBinding.atom, this.updateFresnelFalloff);
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
    this.material.uSpecPhong = value;
  };

  private updateSpecPhongIntensity = (value: number) => {
    this.material.uSpecPhongIntensity = value;
  };

  private toggleSpecMap = (value: boolean) => {
    this.material.uSpecMapEnabled = value;
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
