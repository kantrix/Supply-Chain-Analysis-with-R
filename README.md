# Supply Chain Analysis with R

![image](https://github.com/user-attachments/assets/2e641cbe-368d-4e9b-8fee-b17334dcdcee)

This Supply Chain Analysis project uses R programming to optimize and analyze supply chain operations by leveraging data cleaning, visualization, and exploratory analysis to uncover key insights, such as cost-saving opportunities, demand patterns, and process inefficiencies. The insights derived help businesses streamline their processes and improve decision-making for a more efficient supply chain.

---

## **About Dataset**  

This project focuses on analyzing supply chain performance using structured and unstructured datasets from DataCo Global. Insights were derived from key metrics like transaction types, delivery statuses, shipping modes, customer segments, and sales distribution. The analysis provides actionable recommendations for improving operational efficiency and customer satisfaction.

---

#### **Insights, Key Metrics, and Analysis**

1. **Transaction Types**
   
      ![image](https://github.com/user-attachments/assets/d6aa13bf-effd-4108-84b8-85e5eb1e361f)

   - **Distribution:**  
     - *Debit* accounts for 38.4% of transactions, followed by *Transfer* (27.6%), *Payment* (23.1%), and *Cash* (10.9%).  
   - **Key Insight:** The majority of customers prefer non-cash payment modes, indicating a high reliance on electronic payments.

3. **Delivery Statuses**  

      ![image](https://github.com/user-attachments/assets/95510950-9938-4367-8063-6a0497923658)
      
    - **Distribution:**  
     - 54.8% of deliveries are *Late*, while only 17.8% are *On Time*.  
   - **Key Insight:** A significant portion of deliveries faces delays, highlighting potential inefficiencies in the supply chain.  

5. **Shipping Modes**  

      ![image](https://github.com/user-attachments/assets/820c5297-7985-4aad-84c6-975ac1b266fa)

   - **Distribution:**  
     - *Standard Class* dominates (59.7%), while *Second Class* (19.5%) and *First Class* (15.4%) are also notable.  
   - **Key Insight:** Heavy reliance on *Standard Class* may contribute to delayed deliveries.

7. **Late Deliveries by Category**

      ![image](https://github.com/user-attachments/assets/84097022-f0e8-4724-be62-c95fea1587e1)

   - Categories like *Cleats* (13,496), *Men's Footwear* (12,121), and *Women's Apparel* (11,478) experience the highest late deliveries.  
   - **Key Insight:** Certain product categories are more prone to delivery delays, potentially impacting customer satisfaction.

9. **Top Countries by Average Sales per Customer**  

      ![image](https://github.com/user-attachments/assets/9902cb75-d0af-4e27-9950-f75d50260661)

   - *United States* ($183.03) and *Puerto Rico* ($183.23) show the highest average sales per customer.  
   - **Key Insight:** These regions are key contributors to revenue, warranting focused sales and marketing strategies.

11. **Customer Segments by Profit Contribution**  
         
     ![image](https://github.com/user-attachments/assets/2b51c54b-5231-4036-ab5a-46a3956b52d9)

   - The *Consumer* segment contributes the most profit ($2,073,487.67).  
   - **Key Insight:** Consumers are the primary profit drivers, necessitating tailored engagement strategies.

11. **Average Sales per Customer by Segment**  

    ![image](https://github.com/user-attachments/assets/db90fdba-2fa3-4704-aa3b-1171958404f7)
   
   - *Consumer* ($183.57), *Corporate* ($183.08), and *Home Office* ($181.82) exhibit comparable sales per customer.  
   - **Key Insight:** The consumer segment slightly leads in sales, indicating its importance in driving revenue.

11. **States with Highest Sales per Customer**  

    ![image](https://github.com/user-attachments/assets/cede9890-092a-42dd-bb8f-52017437254a)

   - *Alabama* ($222.55) has the highest sales per customer.  
   - **Key Insight:** Focused marketing efforts in high-performing states like Alabama can boost sales.

11. **Customer Segments with Highest Late Delivery Risk**  

     ![image](https://github.com/user-attachments/assets/48116dcf-0940-4630-8d63-2b9a152958e0)
   
   - *Home Office* customers face the highest late delivery risk (55.07%).  
   - **Key Insight:** Delivery inefficiencies in this segment could lead to customer dissatisfaction.

12. **Top 10 Customer Cities by Total Profit**

     ![image](https://github.com/user-attachments/assets/cb802607-1ac2-4333-b916-73a8a38f142c)

13. **Top 10 Categories by Profit**

     ![image](https://github.com/user-attachments/assets/612f06ca-87ee-470c-8b4c-cac41b4f2892)

14. **Top 10 Products by Sales**

    ![image](https://github.com/user-attachments/assets/d572c9e9-a23f-4ee4-a70a-e98ef8b7481c)

15. **Top 10 Products with Highest Late Delivery Risk**

    ![image](https://github.com/user-attachments/assets/4260fc6e-bd09-4655-9768-b55f05be3a66)

---

#### **Conclusions**

- A large proportion of late deliveries and heavy reliance on *Standard Class* shipping indicate inefficiencies in the supply chain.  
- Certain product categories and customer segments face a higher risk of late deliveries, impacting overall customer satisfaction.  
- The *Consumer* segment and regions like the *United States* and *Puerto Rico* are critical revenue drivers.  

---

#### **Recommendations**

1. **Improve Delivery Timeliness:**  
   - Optimize logistics for late-prone categories like *Cleats* and *Men’s Footwear*.  
   - Transition more shipments to faster shipping modes like *First Class* or *Second Class* for time-sensitive orders.  

2. **Enhance Customer Satisfaction:**  
   - Address late delivery risks in the *Home Office* segment through better planning and monitoring.  
   - Focus on reducing delays for *High Sales* regions like *Alabama* and *Puerto Rico*.  

3. **Leverage High-Performing Segments:**  
   - Prioritize marketing and retention efforts in the *Consumer* segment to capitalize on its profitability.  
   - Develop targeted promotions for high-revenue states and countries.  

4. **Streamline Payment Methods:**  
   - Ensure seamless integration of electronic payment options, as they dominate transaction types.  
