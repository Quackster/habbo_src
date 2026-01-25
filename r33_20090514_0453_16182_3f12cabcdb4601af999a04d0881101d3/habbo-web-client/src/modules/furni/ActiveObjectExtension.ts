/**
 * Active Object Extension Class - Animated/stateful floor furniture
 *
 * Ported from: hh_furni_classes/Cast External ParentScript 6 - Active Object Extension Class.ls
 */

import { ActiveObject } from './ActiveObject';
import {
  FurnitureDefinition,
  AnimationData,
  LayerData,
  StateSequence,
  DEFAULT_INK,
  DEFAULT_BLEND,
} from './types';

/**
 * Active object extension - animated furniture with states
 */
export class ActiveObjectExtension extends ActiveObject {
  protected pStateSequenceList: StateSequence[] = [];
  protected pStateIndex: number = 1;
  protected pState: number = 1;
  protected pLayerDataList: Map<string, LayerData[]> = new Map();
  protected pStateStringList: string[] = [];
  protected pFrameSequenceNumberList: number[] = [];
  protected pFrameNumberList: number[] = [];
  protected pFrameNumberList2: number[] = [];
  protected pLoopCountList: number[] = [];
  protected pFrameRepeatList: number[] = [];
  protected pBlendList: number[] = [];
  protected pInkList: number[] = [];
  protected pIsAnimatingList: number[] = [];
  protected pNameBase: string = '';
  protected pInitialized: boolean = false;

  deconstruct(): void {
    this.pStateSequenceList = [];
    this.pStateIndex = 1;
    this.pState = 1;
    this.pLayerDataList = new Map();
    this.pStateStringList = [];
    this.pFrameSequenceNumberList = [];
    this.pFrameNumberList = [];
    this.pFrameNumberList2 = [];
    this.pLoopCountList = [];
    this.pFrameRepeatList = [];
    this.pBlendList = [];
    this.pInkList = [];
    this.pIsAnimatingList = [];
    this.pInitialized = false;
    super.deconstruct();
  }

  /**
   * Define the animated furniture
   */
  define(data: FurnitureDefinition): boolean {
    // Reset animation state
    this.pStateSequenceList = [];
    this.pStateIndex = 1;
    this.pState = 1;
    this.pLayerDataList = new Map();
    this.pStateStringList = [];
    this.pFrameSequenceNumberList = [];
    this.pFrameNumberList = [];
    this.pFrameNumberList2 = [];
    this.pLoopCountList = [];
    this.pFrameRepeatList = [];
    this.pBlendList = [];
    this.pInkList = [];
    this.pIsAnimatingList = [];

    // Get class name without special suffix
    let className = data.class;
    const starIndex = className.indexOf('*');
    if (starIndex > 0) {
      className = className.substring(0, starIndex);
    }
    this.pNameBase = className;

    if (this.pXFactor === 32) {
      this.pNameBase = 's_' + this.pNameBase;
    }

    // Would load animation data from {class}.data file
    const animData = this.loadAnimationData(this.pNameBase);
    if (animData) {
      this.pStateSequenceList = animData.states || [];
      this.processLayerData(animData.layers || {});

      if (!this.validateStateSequenceList()) {
        this.pStateSequenceList = [];
      }
    }

    this.resetFrameNumbers();

    // Set up ink/blend for each layer
    const layerCount = Math.max(1, this.pLayerDataList.size);
    for (let layer = 0; layer < layerCount; layer++) {
      const layerName = this.getLayerNameByIndex(layer);
      this.pInkList[layer] = this.solveInk(layerName, this.pNameBase);
      this.pBlendList[layer] = this.solveBlend(layerName, this.pNameBase);
    }

    this.pInitialized = false;
    return super.define(data);
  }

  /**
   * Prepare with initial state
   */
  protected prepare(data?: Record<string, unknown>): boolean {
    let state = data?.stuffdata as string | number | undefined;

    if (typeof state === 'string') {
      const stateIndex = this.pStateStringList.indexOf(state);
      if (stateIndex >= 0) {
        state = stateIndex;
      }
    }

    this.setState(state);
    this.resetFrameNumbers();
    return super.prepare(data);
  }

  /**
   * Handle selection (double-click advances state)
   */
  select(): boolean {
    // Would check for double-click
    this.getNextState();
    return true;
  }

  /**
   * Update animation (call each frame)
   */
  update(): boolean {
    // Check if any layer is animating
    if (!this.pIsAnimatingList.includes(1)) {
      return true;
    }

    const isAnimatingList: number[] = [];

    for (let layerIndex = 0; layerIndex < this.pLayerDataList.size; layerIndex++) {
      const layerName = this.getLayerNameByIndex(layerIndex);
      const frameList = this.getFrameList(layerName);

      isAnimatingList[layerIndex] = this.pIsAnimatingList[layerIndex] || 0;

      if (!frameList || !isAnimatingList[layerIndex]) continue;

      if (!frameList.frames && !frameList.sequences) continue;

      const delay = frameList.delay || 1;

      if (this.pFrameRepeatList[layerIndex] >= delay) {
        let loop = true;
        let frameCount = 0;
        let sequenceCount = 0;

        if (frameList.frames) {
          frameCount = frameList.frames.length;
        } else if (frameList.sequences) {
          const seqIndex = this.pFrameSequenceNumberList[layerIndex] || 0;
          if (seqIndex < frameList.sequences.length) {
            frameCount = frameList.sequences[seqIndex].length;
            sequenceCount = frameList.sequences.length;
          }
        }

        if (frameCount > 0) {
          // Check if at end of animation
          if (this.pFrameNumberList[layerIndex] === frameCount) {
            if (this.pLoopCountList[layerIndex] > 0) {
              this.pLoopCountList[layerIndex]--;
            }
            loop = this.pLoopCountList[layerIndex] > 0;
            if (this.pLoopCountList[layerIndex] === 0) {
              isAnimatingList[layerIndex] = 0;
            }
          }

          // Advance frame
          if (this.pFrameNumberList[layerIndex] < frameCount || loop) {
            if (sequenceCount > 0 && this.pFrameNumberList[layerIndex] === frameCount) {
              // Random next sequence
              this.pFrameSequenceNumberList[layerIndex] = Math.floor(Math.random() * sequenceCount);
              this.pFrameNumberList[layerIndex] = 0;
            } else {
              this.pFrameNumberList[layerIndex] = (this.pFrameNumberList[layerIndex] % frameCount) + 1;
            }

            // Handle random frames
            if (frameList.random && frameCount > 1) {
              let value = Math.floor(Math.random() * frameCount) + 1;
              if (value === this.pFrameNumberList2[layerIndex]) {
                value = (this.pFrameNumberList2[layerIndex] % frameCount) + 1;
              }
              this.pFrameNumberList2[layerIndex] = value;
            } else {
              this.pFrameNumberList2[layerIndex] = this.pFrameNumberList[layerIndex];
            }

            // Apply blend if specified per frame
            if (frameList.blend && this.pSprList[layerIndex]) {
              const frameNum = this.pFrameNumberList2[layerIndex];
              if (frameNum <= frameList.blend.length) {
                this.pSprList[layerIndex].blend = frameList.blend[frameNum - 1];
              }
            }
          }
        }

        this.pFrameRepeatList[layerIndex] = 1;
      } else {
        this.pFrameRepeatList[layerIndex]++;
      }
    }

    this.solveMembers();

    // Update animating list
    for (let i = 0; i < isAnimatingList.length; i++) {
      this.pIsAnimatingList[i] = isAnimatingList[i];
    }

    return true;
  }

  /**
   * Resolve members for current animation state
   */
  protected solveMembers(): boolean {
    if (!this.pInitialized) {
      super.solveMembers();
    }

    let membersFound = 0;
    const layerCount = Math.max(this.pLocShiftList.length, this.pLayerDataList.size);

    for (let layerIndex = 0; layerIndex < layerCount; layerIndex++) {
      let animating = true;
      if (layerIndex < this.pIsAnimatingList.length) {
        animating = this.pIsAnimatingList[layerIndex] === 1;
      }

      if (animating) {
        const layerName = this.getLayerNameByIndex(layerIndex);
        const memName = this.getMemberNameForLayer(layerName);

        // Check if we need to add a new sprite
        if (layerIndex >= this.pSprList.length) {
          this.pSprList.push({
            memberName: memName,
            x: 0,
            y: 0,
            z: 0,
            width: 64,
            height: 64,
            ink: this.pInkList[layerIndex] || DEFAULT_INK,
            blend: this.pBlendList[layerIndex] || DEFAULT_BLEND,
            visible: true,
          });
        } else {
          this.pSprList[layerIndex].memberName = memName;
        }

        if (this.memberExists(memName)) {
          membersFound++;
        }
      } else {
        // Check existing sprite
        if (layerIndex < this.pSprList.length) {
          if (this.memberExists(this.pSprList[layerIndex].memberName)) {
            membersFound++;
          }
        }
      }
    }

    this.pInitialized = true;
    return membersFound > 0;
  }

  /**
   * Get member name for a layer
   */
  protected getMemberNameForLayer(layerName: string): string {
    const layerIndex = this.getLayerIndexByName(layerName);
    const frameList = this.getFrameList(layerName);

    const direction = this.pDirection[0] || 0;
    let frame = 0;

    if (frameList && layerIndex >= 0) {
      let frameSequence: number[] | undefined;

      if (frameList.frames) {
        frameSequence = frameList.frames;
      } else if (frameList.sequences) {
        const seqNum = this.pFrameSequenceNumberList[layerIndex] || 0;
        if (seqNum < frameList.sequences.length) {
          frameSequence = frameList.sequences[seqNum];
        }
      }

      if (frameSequence) {
        const frameNum = this.pFrameNumberList2[layerIndex] || 0;
        if (frameNum > 0 && frameNum <= frameSequence.length) {
          frame = frameSequence[frameNum - 1];
          if (frame < 0) {
            frame = Math.floor(Math.random() * Math.abs(frame)) + 1;
          }
        }
      }
    }

    return `${this.pNameBase}_${layerName}_0_${this.pDimensions[0] || 1}_${this.pDimensions[1] || 1}_${direction}_${frame}`;
  }

  /**
   * Get frame list for a layer
   */
  protected getFrameList(layerName: string): LayerData | undefined {
    const layerData = this.pLayerDataList.get(layerName);
    if (!layerData) return undefined;

    const action = this.pState;
    const actionIndex = Math.min(action, layerData.length) - 1;

    if (actionIndex >= 0 && actionIndex < layerData.length) {
      return layerData[actionIndex];
    }

    return undefined;
  }

  /**
   * Update stuff data (state)
   */
  updateStuffdata(value: string | number): void {
    if (typeof value === 'string') {
      const stateIndex = this.pStateStringList.indexOf(value);
      if (stateIndex >= 0) {
        value = stateIndex;
      }
    }

    this.setState(value);
  }

  /**
   * Set state
   */
  setState(newState: string | number | undefined): boolean {
    // Reset loop counts
    for (let layer = 0; layer < this.pLayerDataList.size; layer++) {
      this.pLoopCountList[layer] = 0;
    }

    if (newState === '' || newState === undefined) {
      newState = 0;
    }

    let state = typeof newState === 'string' ? parseInt(newState, 10) : newState;
    if (isNaN(state)) return false;

    state = state + 1; // States are 1-indexed internally

    // Find state in sequence list
    let newIndex = 0;
    for (let i = 0; i < this.pStateSequenceList.length; i++) {
      const seq = this.pStateSequenceList[i];
      if (Array.isArray(seq)) {
        if (seq.includes(state)) {
          newIndex = i + 1;
          break;
        }
      } else {
        if (seq === state) {
          newIndex = i + 1;
          break;
        }
      }
    }

    // Default to first state if not found
    if (newIndex === 0 && this.pStateSequenceList.length > 0) {
      const firstSeq = this.pStateSequenceList[0];
      if (Array.isArray(firstSeq) && firstSeq.length > 0) {
        state = firstSeq[0];
      } else if (typeof firstSeq === 'number') {
        state = firstSeq;
      }
      newIndex = 1;
    }

    if (newIndex !== 0) {
      this.pStateIndex = newIndex;
      this.pState = state;
      this.resetFrameNumbers();

      // Set up loop counts
      for (let layer = 0; layer < this.pLayerDataList.size; layer++) {
        const layerName = this.getLayerNameByIndex(layer);
        const frameList = this.getFrameList(layerName);
        if (frameList) {
          const loop = (frameList.loop || 1) - 1;
          this.pLoopCountList[layer] = loop;
        }
      }

      this.solveMembers();
      this.updateLocation();
      return true;
    }

    return false;
  }

  /**
   * Request next state from server
   */
  getNextState(): void {
    // Would send USEFURNITURE command to server
  }

  /**
   * Reset frame numbers for all layers
   */
  protected resetFrameNumbers(): void {
    this.pFrameRepeatList = [];
    this.pIsAnimatingList = [];
    this.pFrameNumberList = [];
    this.pFrameNumberList2 = [];
    this.pFrameSequenceNumberList = [];

    const count = Math.max(this.pLocShiftList.length, this.pLayerDataList.size);
    for (let i = 0; i < count; i++) {
      this.pFrameSequenceNumberList[i] = 0;
      this.pFrameNumberList[i] = 1;
      this.pFrameNumberList2[i] = 1;
      this.pFrameRepeatList[i] = 1;
      this.pIsAnimatingList[i] = 1;
    }
  }

  /**
   * Validate state sequence list
   */
  protected validateStateSequenceList(): boolean {
    const stateSet = new Set<number>();

    for (const seq of this.pStateSequenceList) {
      if (Array.isArray(seq)) {
        if (seq.length === 0) return false;
        for (const state of seq) {
          if (state < 1) return false;
          if (stateSet.has(state)) return false;
          stateSet.add(state);
        }
      } else {
        if (seq < 1) return false;
        if (stateSet.has(seq)) return false;
        stateSet.add(seq);
      }
    }

    return true;
  }

  /**
   * Load animation data (would load from .data file)
   */
  protected loadAnimationData(nameBase: string): AnimationData | null {
    // In a real implementation, this would load from {nameBase}.data file
    return null;
  }

  /**
   * Process layer data from animation data
   */
  protected processLayerData(layers: Record<string, LayerData[]>): void {
    this.pLayerDataList = new Map();

    for (const [key, value] of Object.entries(layers)) {
      // Keys might be combined like "ab" meaning both layers a and b
      for (const char of key) {
        const lowerChar = char.toLowerCase();
        this.pLayerDataList.set(lowerChar, value);
      }
    }

    // Sort by layer name
    const sortedMap = new Map([...this.pLayerDataList.entries()].sort());
    this.pLayerDataList = sortedMap;
  }

  /**
   * Get layer name by index
   */
  protected getLayerNameByIndex(index: number): string {
    const entries = Array.from(this.pLayerDataList.keys());
    if (index < entries.length) {
      return entries[index];
    }
    return String.fromCharCode('a'.charCodeAt(0) + index);
  }

  /**
   * Get layer index by name
   */
  protected getLayerIndexByName(name: string): number {
    const entries = Array.from(this.pLayerDataList.keys());
    return entries.indexOf(name);
  }

  /**
   * Check if layer is transparent
   */
  protected solveTransparency(part: string): boolean {
    // Would load from .props file
    return false;
  }

  /**
   * Get current state
   */
  getState(): number {
    return this.pState;
  }
}
