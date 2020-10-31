<?php

namespace App\Http\Resources\Admin;

use App\Http\Resources\AddressResource;
use App\Http\Resources\PrivateUserResource;
use App\Http\Resources\ProductVariationResource;
use App\Http\Resources\ShippingMethodResource;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'created_at' => $this->created_at->toDateTimeString(),
            'subtotal' => $this->subtotal->formatted(),
            'total' => $this->total()->formatted(),
            'products' => new ProductVariationResource(
                $this->products()->first()
            ),
            'user' => new PrivateUserResource($this->user),
            'address' => new AddressResource(
                $this->address
            ),
            'shippingMethod' => new ShippingMethodResource(
                $this->shippingMethod
            )
        ];
    }
}
