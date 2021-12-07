import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatInputModule } from '@angular/material/input';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatTooltipModule } from '@angular/material/tooltip';
import { ClipboardModule } from '@angular/cdk/clipboard';
@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    MatInputModule,
    MatIconModule,
    MatFormFieldModule,
    MatTooltipModule,
    ClipboardModule,
  ],
  exports: [
    MatInputModule,
    MatIconModule,
    MatFormFieldModule,
    MatTooltipModule,
    ClipboardModule,
  ],
})
export class MaterialModule {}
