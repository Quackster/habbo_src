/**
 * Shared Module - Common utilities and services
 *
 * Ported from: hh_shared/*.ls
 *
 * This module provides:
 * - Sound system (SoundManager, SoundChannel, SoundInstance)
 * - Date formatting (DateFormatter)
 * - Help tooltips (HelpTooltipManager)
 * - UI animation (ElementBouncer)
 * - Analytics tracking (StatisticsBroker)
 * - Asset loading tracking (LoadWatcher)
 * - Moderation/CFH system (Hobba module)
 * - Error reporting (ErrorReport module)
 *
 * Usage:
 * ```typescript
 * import {
 *   createSharedModule,
 *   SoundManager,
 *   DateFormatter,
 *   HelpTooltipManager
 * } from './modules/shared';
 *
 * // Create shared module with all services
 * const shared = createSharedModule();
 * shared.initialize();
 *
 * // Use sound manager
 * shared.soundManager.play('click.wav', 'pass');
 *
 * // Format dates
 * const formatted = shared.dateFormatter.getLocalDate(1, 12, 2024);
 *
 * // Show tooltip
 * shared.tooltipManager.showTooltip('Help text', 100, 200);
 *
 * // Clean up
 * shared.destroy();
 * ```
 */

// Types
export * from './types';

// Individual utilities
export { DateFormatter } from './DateFormatter';
export { HelpTooltipManager } from './HelpTooltipManager';
export { ElementBouncer } from './ElementBouncer';
export { StatisticsBroker } from './StatisticsBroker';
export { LoadWatcher } from './LoadWatcher';

// Sound module
export * from './sound';

// Hobba (Moderation) module
export * from './hobba';

// Error Report module
export * from './error';

// Imports for factory function
import { SoundManager } from './sound';
import { DateFormatter } from './DateFormatter';
import { HelpTooltipManager } from './HelpTooltipManager';
import { ElementBouncer } from './ElementBouncer';
import { StatisticsBroker } from './StatisticsBroker';
import { LoadWatcher } from './LoadWatcher';
import { createHobbaModule, HobbaModule } from './hobba';
import { createErrorReportModule, ErrorReportModule } from './error';

/**
 * Shared module instance
 */
export interface SharedModule {
  soundManager: SoundManager;
  dateFormatter: DateFormatter;
  tooltipManager: HelpTooltipManager;
  elementBouncer: ElementBouncer;
  statisticsBroker: StatisticsBroker;
  loadWatcher: LoadWatcher;
  hobba: HobbaModule;
  errorReport: ErrorReportModule;

  initialize(): void;
  destroy(): void;
}

/**
 * Create shared module with all services
 */
export function createSharedModule(): SharedModule {
  const soundManager = new SoundManager();
  const dateFormatter = new DateFormatter();
  const tooltipManager = new HelpTooltipManager();
  const elementBouncer = new ElementBouncer();
  const statisticsBroker = new StatisticsBroker();
  const loadWatcher = new LoadWatcher();
  const hobba = createHobbaModule();
  const errorReport = createErrorReportModule();

  return {
    soundManager,
    dateFormatter,
    tooltipManager,
    elementBouncer,
    statisticsBroker,
    loadWatcher,
    hobba,
    errorReport,

    initialize(): void {
      soundManager.construct();
      dateFormatter.construct();
      tooltipManager.construct();
      elementBouncer.construct();
      statisticsBroker.construct();
      loadWatcher.construct();
      hobba.initialize();
      errorReport.initialize();
    },

    destroy(): void {
      errorReport.destroy();
      hobba.destroy();
      loadWatcher.deconstruct();
      statisticsBroker.deconstruct();
      elementBouncer.deconstruct();
      tooltipManager.deconstruct();
      dateFormatter.deconstruct();
      soundManager.deconstruct();
    },
  };
}
