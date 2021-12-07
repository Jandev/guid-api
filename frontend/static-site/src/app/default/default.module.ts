import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { DefaultRoutingModule } from './default-routing.module';
import { DefaultPageComponent } from './default-page/default-page.component';
import { SharedModule } from '../shared/shared.module';

@NgModule({
  declarations: [DefaultPageComponent],
  imports: [CommonModule, DefaultRoutingModule, SharedModule],
})
export class DefaultModule {}
