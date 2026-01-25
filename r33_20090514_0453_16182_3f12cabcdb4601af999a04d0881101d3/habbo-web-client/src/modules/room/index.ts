/**
 * Room Module Exports
 *
 * Complete room system ported from hh_room:
 * - Room geometry and coordinate transformation
 * - Room objects (users, furniture, wall items)
 * - Room component (object management)
 * - Room interface (visual rendering, interaction)
 * - Room handler (server message handling)
 */

// Types
export * from './types';

// Geometry
export { RoomGeometry } from './RoomGeometry';

// Room Objects
export {
  BaseRoomObject,
  ActiveObject,
  PassiveObject,
  ItemObject,
  UserObject,
} from './RoomObjects';

// Room Component
export {
  RoomComponent,
  getRoomComponent,
  resetRoomComponent,
} from './RoomComponent';

// Room Interface
export {
  RoomInterface,
  RoomHiliter,
  ObjectMover,
  getRoomInterface,
  resetRoomInterface,
} from './RoomInterface';

// Room Handler
export {
  RoomHandler,
  getRoomHandler,
  resetRoomHandler,
} from './RoomHandler';
